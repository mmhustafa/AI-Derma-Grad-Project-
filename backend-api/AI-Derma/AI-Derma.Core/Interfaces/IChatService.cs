using AI_Derma.Core.DTOs;
using System;
using System.Collections.Generic;
using System.Text;

namespace AI_Derma.Core.Interfaces
{
    public interface IChatService 
    {
        Task<string> GetResponseAsync(ChatRequestDto request);
    }
}
