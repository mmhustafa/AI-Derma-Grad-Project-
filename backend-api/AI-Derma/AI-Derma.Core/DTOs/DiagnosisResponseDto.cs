using System;
using System.Collections.Generic;
using System.Text;

namespace AI_Derma.Core.DTOs
{
    public class DiagnosisResponseDto
    {
        public string Type { get; set; } 
        public string QuestionCode { get; set; }
        public object QuestionData { get; set; }
        public string Disease { get; set; }
        public float Confidence { get; set; }
        public int DiagnosticResultId { get; set; }
    }
}
