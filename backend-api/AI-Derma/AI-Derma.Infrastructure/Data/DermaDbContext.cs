using AI_Derma.Core.Models;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Text;

namespace AI_Derma.Infrastructure.Data
{
    public class DermaDbContext : IdentityDbContext<ApplicationUser>
    {
        public DermaDbContext(DbContextOptions<DermaDbContext> op) : base(op)
        {

        }
        public DbSet<DiagnosticResult> DiagnosticResults { get; set; }
        public DbSet<Disease> Diseases { get; set; }
        public DbSet<Feedback> Feedbacks { get; set; }
        public DbSet<SymptomAnswer> SymptomAnswers { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Feedback>()
                .HasOne(f => f.Result)
                .WithOne(r => r.Feedback)
                .HasForeignKey<Feedback>(f => f.ResultId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Feedback>()
                .HasOne(f => f.User)
                .WithMany(u => u.Feedbacks)
                .HasForeignKey(f => f.UserId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}