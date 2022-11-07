using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Api.Migrations
{
    /// <inheritdoc />
    public partial class second : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Comments_UserPost_UserPostId",
                table: "Comments");

            migrationBuilder.DropForeignKey(
                name: "FK_PostImages_UserPost_UserPostId",
                table: "PostImages");

            migrationBuilder.DropForeignKey(
                name: "FK_UserPost_Users_UserId",
                table: "UserPost");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserPost",
                table: "UserPost");

            migrationBuilder.RenameTable(
                name: "UserPost",
                newName: "UserPosts");

            migrationBuilder.RenameColumn(
                name: "name",
                table: "UserPosts",
                newName: "Name");

            migrationBuilder.RenameIndex(
                name: "IX_UserPost_UserId",
                table: "UserPosts",
                newName: "IX_UserPosts_UserId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserPosts",
                table: "UserPosts",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Comments_UserPosts_UserPostId",
                table: "Comments",
                column: "UserPostId",
                principalTable: "UserPosts",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_PostImages_UserPosts_UserPostId",
                table: "PostImages",
                column: "UserPostId",
                principalTable: "UserPosts",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserPosts_Users_UserId",
                table: "UserPosts",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Comments_UserPosts_UserPostId",
                table: "Comments");

            migrationBuilder.DropForeignKey(
                name: "FK_PostImages_UserPosts_UserPostId",
                table: "PostImages");

            migrationBuilder.DropForeignKey(
                name: "FK_UserPosts_Users_UserId",
                table: "UserPosts");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UserPosts",
                table: "UserPosts");

            migrationBuilder.RenameTable(
                name: "UserPosts",
                newName: "UserPost");

            migrationBuilder.RenameColumn(
                name: "Name",
                table: "UserPost",
                newName: "name");

            migrationBuilder.RenameIndex(
                name: "IX_UserPosts_UserId",
                table: "UserPost",
                newName: "IX_UserPost_UserId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_UserPost",
                table: "UserPost",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Comments_UserPost_UserPostId",
                table: "Comments",
                column: "UserPostId",
                principalTable: "UserPost",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_PostImages_UserPost_UserPostId",
                table: "PostImages",
                column: "UserPostId",
                principalTable: "UserPost",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_UserPost_Users_UserId",
                table: "UserPost",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
