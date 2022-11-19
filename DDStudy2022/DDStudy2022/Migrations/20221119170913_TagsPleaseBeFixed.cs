using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Api.Migrations
{
    /// <inheritdoc />
    public partial class TagsPleaseBeFixed : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PostTagUserPost");

            migrationBuilder.DropTable(
                name: "PostTags");

            migrationBuilder.AddColumn<string>(
                name: "TagString",
                table: "UserPosts",
                type: "text",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "TagString",
                table: "UserPosts");

            migrationBuilder.CreateTable(
                name: "PostTags",
                columns: table => new
                {
                    Tag = table.Column<string>(type: "text", nullable: false),
                    UserPostId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PostTags", x => new { x.Tag, x.UserPostId });
                });

            migrationBuilder.CreateTable(
                name: "PostTagUserPost",
                columns: table => new
                {
                    UserPostsId = table.Column<Guid>(type: "uuid", nullable: false),
                    PostTagsTag = table.Column<string>(type: "text", nullable: false),
                    PostTagsUserPostId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PostTagUserPost", x => new { x.UserPostsId, x.PostTagsTag, x.PostTagsUserPostId });
                    table.ForeignKey(
                        name: "FK_PostTagUserPost_PostTags_PostTagsTag_PostTagsUserPostId",
                        columns: x => new { x.PostTagsTag, x.PostTagsUserPostId },
                        principalTable: "PostTags",
                        principalColumns: new[] { "Tag", "UserPostId" },
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PostTagUserPost_UserPosts_UserPostsId",
                        column: x => x.UserPostsId,
                        principalTable: "UserPosts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_PostTagUserPost_PostTagsTag_PostTagsUserPostId",
                table: "PostTagUserPost",
                columns: new[] { "PostTagsTag", "PostTagsUserPostId" });
        }
    }
}
