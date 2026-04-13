using AI_Derma.Core.Interfaces;
using AI_Derma.Core.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AI_Derma.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class HistoryController : ControllerBase
    {
        IUnitofWork unitofWork;
        UserManager<ApplicationUser> userManager;
        public HistoryController(IUnitofWork _unitofWork, UserManager<ApplicationUser> _usermanager)
        {
            unitofWork = _unitofWork;
            userManager = _usermanager;
        }

        [HttpGet("diagnostics")]
        public async Task<IActionResult> GetDiagnosticHistory()
        {
            var user = await userManager.GetUserAsync(User);

            //var userid = User.FindFirstValue(ClaimTypes.NameIdentifier);

            var results=await unitofWork.DiagnosticResults.GetByUserIdAsync(user.Id);

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
