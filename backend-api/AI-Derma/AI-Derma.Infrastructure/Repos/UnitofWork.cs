using AI_Derma.Core.Interfaces;
using AI_Derma.Core.Models;
using AI_Derma.Infrastructure.Data;
using System;
using System.Collections.Generic;
using System.Text;

namespace AI_Derma.Infrastructure.Repos
{
    public class UnitofWork : IUnitofWork
    {
        private readonly DermaDbContext _context;

        public IDiagnosticResultRepository DiagnosticResults { get; }
        public ISymptomAnswerRepository SymptomAnswers { get; }
        public IGenericRepository<Disease> Diseases { get; }

        public UnitofWork(DermaDbContext context)
        {
            _context = context;
            DiagnosticResults = new DiagnosticResultRepository(context);
            SymptomAnswers = new SymptomAnswerRepository(context);
            Diseases = new GenericRepository<Disease>(context);
        }

        public async Task<int> CompleteAsync()
        {
            return await _context.SaveChangesAsync();
        }

        public void Dispose()
        {
            _context.Dispose();
        }
    }
}
