using System;
using System.Collections.Generic;
using System.Text;

namespace AI_Derma.Core.DTOs
{
    public class SaveAnswerDto
    {
        public int DiagnosticResultId { get; set; }
        public string QuestionText { get; set; }
        public string Answer { get; set; }
    }
}
