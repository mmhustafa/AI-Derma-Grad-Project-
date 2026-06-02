using AI_Derma.Core.DTOs;
using AI_Derma.Core.Interfaces;
using AI_Derma.Core.Models;
using AI_Derma.Infrastructure.Repos;
using Azure.Core;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace AI_Derma.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
  //  [Authorize]
    public class DiagnosticController : ControllerBase
    {
        private readonly IUnitofWork unitofWork;
        private readonly UserManager<ApplicationUser> userManager;
        private readonly IFastAPIService fastAPIService;
        private readonly IKBMetadata KB;
        private readonly CloudinaryService cloudinaryService;

        public DiagnosticController(IUnitofWork _unitofWork, 
            UserManager<ApplicationUser> _userManager, 
            IFastAPIService _fastAPIService, IKBMetadata _kB, CloudinaryService _cloudinaryService)
        {
            this.unitofWork = _unitofWork;
            this.userManager = _userManager;
            this.fastAPIService = _fastAPIService;
            this.KB = _kB;
            this.cloudinaryService = _cloudinaryService;
        }

        [HttpPost("next-step")]
        public async Task<IActionResult> GetNextStep([FromBody] NextStepRequestDto nextStep)
        {
            var result = await fastAPIService.GetNextStepAsync(nextStep.Facts);
            var metadata = KB.questionsMetadata();

            if (result.Type == "question")
            {
                var question = metadata.KnowledgeBase[result.Code];
                return Ok(new DiagnosisResponseDto
                {
                    Type = "question",
                    QuestionCode = result.Code,
                    QuestionData = question,
                    DiagnosticResultId = nextStep.DiagnosticResultId ?? 0
                });
            }

            if (result.Type == "diagnosis")
            {
                var user = await userManager.GetUserAsync(User);
                Console.WriteLine($"User from HttpContext: {user?.Id ?? "null"}, User.Identity.Name: {User?.Identity?.Name ?? "null"}, User.Identity.IsAuthenticated: {User?.Identity?.IsAuthenticated ?? false}");
                
                // Get disease ID from database
                var disease = await unitofWork.Diseases.GetSingleAsync(d => d.DiseaseName.ToLower() == result.Result.ToLower());

                var diagnostic = new DiagnosticResult
                {
                    UserId = user?.Id ,
                    DiseaseId = disease?.Id,
                    SourceType = "Expert System",
                    ConfidenceScore = null
                };

                await unitofWork.DiagnosticResults.AddAsync(diagnostic);
                await unitofWork.CompleteAsync();

                return Ok(new DiagnosisResponseDto
                {
                    Type = "diagnosis",
                    Disease = result.Result,
                    DiagnosticResultId = diagnostic.Id
                });
            }

            return BadRequest();
        }

        [HttpGet("disease-details")]
        public async Task<IActionResult> GetDiseaseDetails([FromQuery] string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                return BadRequest("Disease name is required.");
            }

            var normalizedInput = System.Text.RegularExpressions.Regex.Replace(name, @"\s+", "");

            var allDiseases = await unitofWork.Diseases.GetAllAsync();
            var disease = allDiseases?.FirstOrDefault(d => 
            {
                var normalizedDbName = System.Text.RegularExpressions.Regex.Replace(d.DiseaseName, @"\s+", "");
                return normalizedDbName.Equals(normalizedInput, StringComparison.OrdinalIgnoreCase);
            });

            if (disease == null)
            {
                return NotFound("Disease not found.");
            }

            return Ok(new DiseaseDetailsResponseDto
            {
                DiseaseName = disease.DiseaseName,
                Description = disease.Description,
                SeverityLevel = disease.SeverityLevel,
                CareInstructions = disease.CareInstructions
            });
        }

        [HttpPost("save-answers")]
        public async Task<IActionResult> SaveAnswers([FromBody] SaveAnswersDto dto)
        {
            try
            {
                foreach (var answer in dto.Answers)
                {
                    var symptomAnswer = new SymptomAnswer
                    {
                        DiagnosticResultId = dto.DiagnosticResultId,
                        QuestionText = answer.QuestionText,
                        UserAnswer = answer.Answer
                    };
                    await unitofWork.SymptomAnswers.AddAsync(symptomAnswer);
                }
                await unitofWork.CompleteAsync();
                return Ok(new { success = true });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        
        [HttpPost("predict-image")]
        public async Task<IActionResult> PredictImage([FromForm] ImageDiagnosisRequestDto request)
        {
            if (request.Image == null || request.Image.Length == 0)
            {
                return BadRequest("Image is required.");
            }

            try
            {
                // Upload image to Cloudinary
                var imageUrl = await cloudinaryService.UploadImageAsync(request.Image);

                // Send image to FastAPI model
                var result = await fastAPIService.PredictImageAsync(request.Image);

                var user = await userManager.GetUserAsync(User);

                // Get disease from database
                var disease = await unitofWork.Diseases.GetSingleAsync(
                    d => d.DiseaseName.ToLower() == result.Disease.ToLower()
                );

                // Save diagnostic result
                var diagnostic = new DiagnosticResult
                {
                    UserId = user?.Id,

                    DiseaseId = disease?.Id,

                    ImageUrl = imageUrl,

                    SourceType = "AI Model",

                    ConfidenceScore = result.Confidence
                };

                await unitofWork.DiagnosticResults.AddAsync(diagnostic);

                await unitofWork.CompleteAsync();

                return Ok(new
                {
                    Disease = result.Disease,
                    Confidence = result.Confidence,
                    Top3 = result.Top3,
                    DiagnosticResultId = diagnostic.Id
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    message = "Prediction failed",
                    error = ex.Message
                });
            }
        }

    }
}
