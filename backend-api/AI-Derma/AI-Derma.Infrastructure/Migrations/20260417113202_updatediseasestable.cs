using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AI_Derma.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class updatediseasestable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Symptoms",
                table: "Diseases");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Symptoms",
                table: "Diseases",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }
    }
}
