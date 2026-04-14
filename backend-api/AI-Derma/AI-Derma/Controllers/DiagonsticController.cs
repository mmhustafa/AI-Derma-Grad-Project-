using AI_Derma.Core.DTOs;
using AI_Derma.Core.Interfaces;
using AI_Derma.Core.Models;
using AI_Derma.Infrastructure.Repos;
using Azure.Core;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace AI_Derma.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DiagonsticController : ControllerBase
    {
        private readonly IUnitofWork unitofWork;
        private readonly UserManager<ApplicationUser> userManager;
        private readonly IFastAPIService fastAPIService;
        private readonly IKBMetadata KB;

        public DiagonsticController(IUnitofWork _unitofWork, 
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

            if(result.type == "question")
            {
                var question = metadata.KnowledgeBase[result.code];
                return Ok(new DiagnosisResponseDto
                {
                    Type = "question",
                    QuestionCode = result.code,
                    QuestionData = question,
                    DiagnosticResultId = nextStep.DiagnosticResultId ?? 0
                });
            }

            if (result.type == "diagnosis")
            {
                var user = await userManager.GetUserAsync(User);

                var diagnostic = new DiagnosticResult
                {
                    UserId = user?.Id,
                    SourceType = "KB",
                    ConfidenceScore = 1,
                    FinalRecommendation = "placeholder"
                };

                await unitofWork.DiagnosticResults.AddAsync(diagnostic);
                await unitofWork.CompleteAsync();

                return Ok(new DiagnosisResponseDto
                {
                    Type = "diagnosis",
                    Disease = result.result,
                    DiagnosticResultId = diagnostic.Id
                });
            }
            return BadRequest();
        }

        [HttpPost("save-answer")]
        public async Task<IActionResult> SaveAnswer([FromBody] SaveAnswerDto dto)
        {
            var answer = new SymptomAnswer
            {
                DiagnosticResultId = dto.DiagnosticResultId,
                QuestionText = dto.QuestionText,
                UserAnswer = dto.Answer
            };

            await unitofWork.SymptomAnswers.AddAsync(answer);
            await unitofWork.CompleteAsync();

            return Ok();
        }


    }
}
