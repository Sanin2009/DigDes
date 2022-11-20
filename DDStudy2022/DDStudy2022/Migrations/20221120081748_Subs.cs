using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Api.Migrations
{
    /// <inheritdoc />
    public partial class Subs : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "SubscriberId",
                table: "Users",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "SubscriberUserId",
                table: "Users",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Subscribers",
                columns: table => new
                {
                    SubscriberId = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    IsSubscribed = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Subscribers", x => new { x.UserId, x.SubscriberId });
                });

            migrationBuilder.CreateIndex(
                name: "IX_Users_SubscriberUserId_SubscriberId",
                table: "Users",
                columns: new[] { "SubscriberUserId", "SubscriberId" });

            migrationBuilder.AddForeignKey(
                name: "FK_Users_Subscribers_SubscriberUserId_SubscriberId",
                table: "Users",
                columns: new[] { "SubscriberUserId", "SubscriberId" },
                principalTable: "Subscribers",
                principalColumns: new[] { "UserId", "SubscriberId" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Users_Subscribers_SubscriberUserId_SubscriberId",
                table: "Users");

            migrationBuilder.DropTable(
                name: "Subscribers");

            migrationBuilder.DropIndex(
                name: "IX_Users_SubscriberUserId_SubscriberId",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "SubscriberId",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "SubscriberUserId",
                table: "Users");
        }
    }
}
