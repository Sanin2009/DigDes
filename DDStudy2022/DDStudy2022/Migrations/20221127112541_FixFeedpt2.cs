using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Api.Migrations
{
    /// <inheritdoc />
    public partial class FixFeedpt2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Users_Subscribers_SubscriberUserId_SubscriberId",
                table: "Users");

            migrationBuilder.DropIndex(
                name: "IX_Users_SubscriberUserId_SubscriberId",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "SubscriberId",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "SubscriberUserId",
                table: "Users");

            migrationBuilder.CreateTable(
                name: "SubscriberUser",
                columns: table => new
                {
                    UsersId = table.Column<Guid>(type: "uuid", nullable: false),
                    SubscribersUserId = table.Column<Guid>(type: "uuid", nullable: false),
                    SubscribersSubscriberId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SubscriberUser", x => new { x.UsersId, x.SubscribersUserId, x.SubscribersSubscriberId });
                    table.ForeignKey(
                        name: "FK_SubscriberUser_Subscribers_SubscribersUserId_SubscribersSub~",
                        columns: x => new { x.SubscribersUserId, x.SubscribersSubscriberId },
                        principalTable: "Subscribers",
                        principalColumns: new[] { "UserId", "SubscriberId" },
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_SubscriberUser_Users_UsersId",
                        column: x => x.UsersId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_SubscriberUser_SubscribersUserId_SubscribersSubscriberId",
                table: "SubscriberUser",
                columns: new[] { "SubscribersUserId", "SubscribersSubscriberId" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "SubscriberUser");

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
    }
}
