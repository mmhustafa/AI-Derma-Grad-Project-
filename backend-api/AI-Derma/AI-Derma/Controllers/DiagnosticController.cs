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

        public DiagnosticController(IUnitofWork _unitofWork, 
            UserManager<ApplicationUser> _userManager, 
            IFastAPIService _fastAPIService, IKBMetadata _kB)
        {
            this.unitofWork = _unitofWork;
            this.userManager = _userManager;
            this.fastAPIService = _fastAPIService;
            this.KB = _kB;
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

            var disease = await unitofWork.Diseases.GetSingleAsync(d => d.DiseaseName.ToLower() == name.Trim().ToLower());
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


    }
}
