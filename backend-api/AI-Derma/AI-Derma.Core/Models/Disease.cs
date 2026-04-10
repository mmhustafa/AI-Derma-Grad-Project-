namespace AI_Derma.Core.Models
{
    public class Disease
    {
        public int Id { get; set; }

        public string DiseaseName { get; set; }

        public string Description { get; set; }

        public string SeverityLevel { get; set; }

        public string CareInstructions { get; set; }

        public string Symptoms { get; set; }
        public ICollection<DiagnosticResult> DiagnosticResults { get; set; }
    }
}