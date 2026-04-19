using System.Collections.Generic;

namespace AI_Derma.Core.DTOs
{
    public class SaveAnswersDto
    {
        public int DiagnosticResultId { get; set; }
        public List<AnswerItemDto> Answers { get; set; }
    }

    public class AnswerItemDto
    {
        public string QuestionText { get; set; }
        public string Answer { get; set; }
    }
}
