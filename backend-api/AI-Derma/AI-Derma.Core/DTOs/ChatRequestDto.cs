using System;
using System.Collections.Generic;
using System.Text;

namespace AI_Derma.Core.DTOs
{
    public class ChatRequestDto
    {
        public string Message { get; set; }
        public string Condition { get; set; }
        public double Confidence { get; set; }
        public string SessionId { get; set; }
    }
}
