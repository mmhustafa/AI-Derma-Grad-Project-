namespace AI_Derma.Core.Models
{
    public class SymptomAnswer
    {
        public int Id { get; set; }

        public int DiagnosticResultId { get; set; }
        public DiagnosticResult DiagnosticResult { get; set; }

        public string QuestionText { get; set; }
        public string UserAnswer { get; set; }

    }
}