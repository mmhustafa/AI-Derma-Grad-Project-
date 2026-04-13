using AI_Derma.Core.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;

namespace AI_Derma.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    //[Authorize]
    public class HistoryController : ControllerBase
    {
        IUnitofWork unitofWork;
        public HistoryController(IUnitofWork _unitofWork)
        {
            unitofWork = _unitofWork;
        }
        [HttpGet("diagnostics/{userid}")]
        public async Task<IActionResult> GetDiagnosticHistory(string userid)
        {
            var results=await unitofWork.DiagnosticResults.GetByUserIdAsync(userid);

            if (results == null || !results.Any())
            {
                return NotFound(new { message = "No History For This User" });
            }

            return Ok(results);

        }
        [HttpGet("diagnostic/{resultId}")]
        public async Task<IActionResult>GetDiagnosticDetails(int resultId)
        {
            var result =await unitofWork.DiagnosticResults.GetbyDiagnosticResultIdAsync(resultId);

            if (result == null)
            {
                return NotFound(new { message = "Not Found" });
            }

            return Ok(result);
        }
    }
}
