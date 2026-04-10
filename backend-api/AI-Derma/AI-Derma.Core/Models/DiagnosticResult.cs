namespace AI_Derma.Core.Models
{
    public class DiagnosticResult
    {
        public int Id { get; set; }

        public string UserId { get; set; }
        public ApplicationUser User { get; set; }

        public int? DiseaseId { get; set; }
        public Disease Disease { get; set; }

        public string ImageUrl { get; set; }

        public string SourceType { get; set; }

        public float ConfidenceScore { get; set; }

        public string FinalRecommendation { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<SymptomAnswer> SymptomAnswers { get; set; }
    }
}