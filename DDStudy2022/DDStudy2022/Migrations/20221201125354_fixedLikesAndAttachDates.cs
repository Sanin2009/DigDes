using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Api.Migrations
{
    /// <inheritdoc />
    public partial class fixedLikesAndAttachDates : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PostLikeUser");

            migrationBuilder.DropTable(
                name: "PostLikeUserPost");

            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "Created",
                table: "Attaches",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTimeOffset(new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 0, 0, 0, 0)));

            migrationBuilder.CreateIndex(
                name: "IX_PostLikes_UserPostId",
                table: "PostLikes",
                column: "UserPostId");

            migrationBuilder.AddForeignKey(
                name: "FK_PostLikes_UserPosts_UserPostId",
                table: "PostLikes",
                column: "UserPostId",
                principalTable: "UserPosts",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_PostLikes_Users_UserId",
                table: "PostLikes",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_PostLikes_UserPosts_UserPostId",
                table: "PostLikes");

            migrationBuilder.DropForeignKey(
                name: "FK_PostLikes_Users_UserId",
                table: "PostLikes");

            migrationBuilder.DropIndex(
                name: "IX_PostLikes_UserPostId",
                table: "PostLikes");

            migrationBuilder.DropColumn(
                name: "Created",
                table: "Attaches");

            migrationBuilder.CreateTable(
                name: "PostLikeUser",
                columns: table => new
                {
                    UsersId = table.Column<Guid>(type: "uuid", nullable: false),
                    PostLikesUserId = table.Column<Guid>(type: "uuid", nullable: false),
                    PostLikesUserPostId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PostLikeUser", x => new { x.UsersId, x.PostLikesUserId, x.PostLikesUserPostId });
                    table.ForeignKey(
                        name: "FK_PostLikeUser_PostLikes_PostLikesUserId_PostLikesUserPostId",
                        columns: x => new { x.PostLikesUserId, x.PostLikesUserPostId },
                        principalTable: "PostLikes",
                        principalColumns: new[] { "UserId", "UserPostId" },
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PostLikeUser_Users_UsersId",
                        column: x => x.UsersId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PostLikeUserPost",
                columns: table => new
                {
                    UserPostsId = table.Column<Guid>(type: "uuid", nullable: false),
                    PostLikesUserId = table.Column<Guid>(type: "uuid", nullable: false),
                    PostLikesUserPostId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PostLikeUserPost", x => new { x.UserPostsId, x.PostLikesUserId, x.PostLikesUserPostId });
                    table.ForeignKey(
                        name: "FK_PostLikeUserPost_PostLikes_PostLikesUserId_PostLikesUserPos~",
                        columns: x => new { x.PostLikesUserId, x.PostLikesUserPostId },
                        principalTable: "PostLikes",
                        principalColumns: new[] { "UserId", "UserPostId" },
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PostLikeUserPost_UserPosts_UserPostsId",
                        column: x => x.UserPostsId,
                        principalTable: "UserPosts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_PostLikeUser_PostLikesUserId_PostLikesUserPostId",
                table: "PostLikeUser",
                columns: new[] { "PostLikesUserId", "PostLikesUserPostId" });

            migrationBuilder.CreateIndex(
                name: "IX_PostLikeUserPost_PostLikesUserId_PostLikesUserPostId",
                table: "PostLikeUserPost",
                columns: new[] { "PostLikesUserId", "PostLikesUserPostId" });
        }
    }
}
