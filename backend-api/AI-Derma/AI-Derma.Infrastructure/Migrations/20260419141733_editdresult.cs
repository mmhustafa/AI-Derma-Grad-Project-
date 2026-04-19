using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AI_Derma.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class editdresult : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "FinalRecommendation",
                table: "DiagnosticResults");

            migrationBuilder.AlterColumn<string>(
                name: "ImageUrl",
                table: "DiagnosticResults",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.AlterColumn<float>(
                name: "ConfidenceScore",
                table: "DiagnosticResults",
                type: "real",
                nullable: true,
                oldClrType: typeof(float),
                oldType: "real");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "ImageUrl",
                table: "DiagnosticResults",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);

            migrationBuilder.AlterColumn<float>(
                name: "ConfidenceScore",
                table: "DiagnosticResults",
                type: "real",
                nullable: false,
                defaultValue: 0f,
                oldClrType: typeof(float),
                oldType: "real",
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "FinalRecommendation",
                table: "DiagnosticResults",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }
    }
}
