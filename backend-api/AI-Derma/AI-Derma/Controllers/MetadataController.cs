using AI_Derma.Core.JsonModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using AI_Derma.Core.Interfaces;
using Microsoft.AspNetCore.Authorization;
namespace AI_Derma.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MetadataController : ControllerBase
    {
        private readonly IKBMetadata _metadataService;

        public MetadataController(IKBMetadata metadataService)
        {
            _metadataService = metadataService;
        }

        [Authorize]
        [HttpGet("knowledge-base")]
        public IActionResult GetKnowledgeBase()
        {
            var metadata = _metadataService.questionsMetadata();
            return Ok(metadata.KnowledgeBase);
        }

        [HttpGet("confirmation/{diseaseName}")]
        public IActionResult GetConfirmationForDisease(string diseaseName)
        {
            if (string.IsNullOrWhiteSpace(diseaseName))
            {
                return BadRequest(new { message = "Disease name is required" });
            }

            var metadata = _metadataService.questionsMetadata();

            // Remove spaces from the incoming disease name for comparison
            var normalizedInput = System.Text.RegularExpressions.Regex.Replace(diseaseName, @"\s+", "");

            // Find matching disease key by removing spaces from both for comparison
            var diseaseKey = metadata.ConfirmationQuestions.Keys
                .FirstOrDefault(k => 
                {
                    var normalizedKey = System.Text.RegularExpressions.Regex.Replace(k, @"\s+", "");
                    return normalizedKey.Equals(normalizedInput, StringComparison.OrdinalIgnoreCase);
                });

            if (diseaseKey != null)
            {
                var questions = metadata.ConfirmationQuestions[diseaseKey];
                if (questions != null && questions.Count > 0)
                {
                    return Ok(questions);
                }
            }

            return BadRequest(new { message = $"No confirmation questions found for disease: {diseaseName}" });
        }
    }
}
