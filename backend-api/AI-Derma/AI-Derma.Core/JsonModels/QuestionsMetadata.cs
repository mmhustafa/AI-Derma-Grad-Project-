    using System;
    using System.Collections.Generic;
    using System.Text;

    namespace AI_Derma.Core.JsonModels
    {
        public class QuestionsMetadata
        {
            public Dictionary<string, QuestionDetail> KnowledgeBase { get; set; }
            public Dictionary<string, List<ConfirmationQuestion>> ConfirmationQuestions { get; set; }
        }
        public class QuestionDetail
        {
            public string Text { get; set; }
            public List<Option> Options { get; set; }
        }

        public class Option
        {
            public string Val { get; set; }
            public string Label { get; set; }
        }

        public class ConfirmationQuestion
        {
            public string QuestionCode { get; set; }
            public string Text { get; set; }
        }
    }
