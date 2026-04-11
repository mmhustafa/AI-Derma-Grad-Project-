using AI_Derma.Core.JsonModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using AI_Derma.Core.Interfaces;
namespace AI_Derma.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MetadataController : ControllerBase
    {
        private readonly IMetadata _metadataService;

        public MetadataController(IMetadata metadataService)
        {
            _metadataService = metadataService;
        }

        [HttpGet("knowledge-base")]
        public IActionResult GetKnowledgeBase()
        {
            var metadata = _metadataService.questionsMetadata();
            return Ok(metadata.KnowledgeBase);
        }

        [HttpGet("confirmation/{diseaseName}")]
        public IActionResult GetConfirmationForDisease(string diseaseName)
        {
            var metadata = _metadataService.questionsMetadata();

            if (metadata.ConfirmationQuestions.ContainsKey(diseaseName))
            {
                var questions = metadata.ConfirmationQuestions[diseaseName];
                return Ok(questions);
            }

            return Ok(new List<ConfirmationQuestion>());
        }
    }
}
