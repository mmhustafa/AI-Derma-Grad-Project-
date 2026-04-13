using AI_Derma.Core.Models;
using System;
using System.Collections.Generic;
using System.Text;

namespace AI_Derma.Core.Interfaces
{
    public interface IUnitofWork : IDisposable
    {
        IDiagnosticResultRepository DiagnosticResults { get; }
        ISymptomAnswerRepository SymptomAnswers { get; }
        IGenericRepository<Disease> Diseases { get; }

        Task<int> CompleteAsync();
    }
}
