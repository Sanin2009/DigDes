using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Api.Migrations
{
    /// <inheritdoc />
    public partial class FixFeedpt3 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "SubscriberUser");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Subscribers",
                table: "Subscribers");

            migrationBuilder.AddColumn<Guid>(
                name: "SubscriberId",
                table: "Users",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "Id",
                table: "Subscribers",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddPrimaryKey(
                name: "PK_Subscribers",
                table: "Subscribers",
                column: "Id");

            migrationBuilder.CreateIndex(
                name: "IX_Users_SubscriberId",
                table: "Users",
                column: "SubscriberId");

            migrationBuilder.AddForeignKey(
                name: "FK_Users_Subscribers_SubscriberId",
                table: "Users",
                column: "SubscriberId",
                principalTable: "Subscribers",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Users_Subscribers_SubscriberId",
                table: "Users");

            migrationBuilder.DropIndex(
                name: "IX_Users_SubscriberId",
                table: "Users");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Subscribers",
                table: "Subscribers");

            migrationBuilder.DropColumn(
                name: "SubscriberId",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "Id",
                table: "Subscribers");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Subscribers",
                table: "Subscribers",
                columns: new[] { "UserId", "SubscriberId" });

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
    }
}
