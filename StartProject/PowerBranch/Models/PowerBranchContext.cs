using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace PowerBranch.Models
{
    public partial class PowerBranchContext : DbContext
    {
        public PowerBranchContext()
        {
        }

        public PowerBranchContext(DbContextOptions<PowerBranchContext> options)
            : base(options)
        {
        }

        public virtual DbSet<Mesures> Mesures { get; set; }
        public virtual DbSet<Points> Points { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. See http://go.microsoft.com/fwlink/?LinkId=723263 for guidance on storing connection strings.
                optionsBuilder.UseSqlServer("Server=tcp:powerbranch-sqlserver.database.windows.net,1433;Initial Catalog=PowerBranch;Persist Security Info=False;User ID=ErZZoiN;Password=Cenl3a5L;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;");
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Mesures>(entity =>
            {
                entity.ToTable("mesures");

                entity.Property(e => e.Id).ValueGeneratedNever();

                entity.Property(e => e.Date)
                    .HasColumnName("date")
                    .HasColumnType("datetime");

                entity.Property(e => e.IsPredicted).HasColumnName("isPredicted");

                entity.Property(e => e.Mesure).HasColumnName("mesure");

                entity.Property(e => e.Point)
                    .HasColumnName("point")
                    .HasMaxLength(255);

                entity.HasOne(d => d.PointNavigation)
                    .WithMany(p => p.Mesures)
                    .HasForeignKey(d => d.Point)
                    .HasConstraintName("FK_mesures_points");
            });

            modelBuilder.Entity<Points>(entity =>
            {
                entity.HasKey(e => e.Name);

                entity.ToTable("points");

                entity.HasIndex(e => e.Name)
                    .HasName("IX_points")
                    .IsUnique();

                entity.Property(e => e.Name)
                    .HasColumnName("name")
                    .HasMaxLength(255);

                entity.Property(e => e.CreationDate)
                    .HasColumnName("creationDate")
                    .HasColumnType("datetime");

                entity.Property(e => e.X).HasColumnName("x");

                entity.Property(e => e.Y).HasColumnName("y");

                entity.Property(e => e.Z).HasColumnName("z");
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
