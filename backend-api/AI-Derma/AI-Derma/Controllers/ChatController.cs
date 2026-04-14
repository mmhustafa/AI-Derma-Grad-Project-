using AI_Derma.Core.DTOs;
using AI_Derma.Core.Interfaces;
using AI_Derma.Infrastructure.Repos;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace AI_Derma.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    //[Authorize]
    public class ChatController : ControllerBase
    {
        private readonly IChatService chatService;

        public ChatController(IChatService _chatService)
        {
            chatService = _chatService;
        }

        [HttpGet("welcome")]
        public IActionResult GetWelcome()
        {
            var userName = User.Identity?.Name ?? "there";

            var message = $"Hello {userName}, I'm your Al-Derma Assistant. Do you have any questions about your skin condition?";

            return Ok(new
            {
                sessionId = Guid.NewGuid().ToString(),
                reply = message
            });
        }

        [HttpPost]
        public async Task<IActionResult> Chat([FromBody] ChatRequestDto request)
        {
            if (string.IsNullOrWhiteSpace(request.Message))
                return BadRequest("Message is required");

            if (string.IsNullOrEmpty(request.SessionId))
                return BadRequest("SessionId is required");

            var reply = await chatService.GetResponseAsync(request);

            return Ok(new ChatResponseDto
            {
                Reply = reply
            });
        }
    }
}
