using System;
using System.Collections.Generic;
using System.Text;

namespace AI_Derma.Core.DTOs
{
    public class NextStepRequestDto
    {
        public List<string> Facts { get; set; } = new();
        public int? DiagnosticResultId { get; set; }
    }
}
