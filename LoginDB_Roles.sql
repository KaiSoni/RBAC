USE [master]
GO

CREATE DATABASE [LoginDB]

GO

USE [LoginDB]
GO

/****** Object:  Table [dbo].[Users]    Script Date: 07/19/2017 16:36:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Users](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[Username] [nvarchar](20) NOT NULL,
	[Password] [nvarchar](20) NOT NULL,
	[Email] [nvarchar](30) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[LastLoginDate] [datetime] NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

USE [LoginDB]
GO

/****** Object:  StoredProcedure [dbo].[Insert_User]    Script Date: 07/19/2017 16:36:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--Insert_User 'Kailash2', '12345', 'kailash@soni.com'
CREATE PROCEDURE [dbo].[Insert_User]
	@Username NVARCHAR(20),
	@Password NVARCHAR(20),
	@Email NVARCHAR(30)
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT UserId FROM Users WHERE Username = @Username)
	BEGIN
		SELECT -1 -- Username exists.
	END
	ELSE IF EXISTS(SELECT UserId FROM Users WHERE Email = @Email)
	BEGIN
		SELECT -2 -- Email exists.
	END
	ELSE
	BEGIN
		INSERT INTO [Users]
			   ([Username]
			   ,[Password]
			   ,[Email]
			   ,[CreatedDate])
		VALUES
			   (@Username
			   ,@Password
			   ,@Email
			   ,GETDATE())
		
		SELECT SCOPE_IDENTITY() -- UserId			   
     END
END

GO

/****** Object:  Table [dbo].[UserActivation]    Script Date: 07/19/2017 21:56:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[UserActivation](
	[UserId] [int] NOT NULL,
	[ActivationCode] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_UserActivation] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE  PROCEDURE [dbo].[Validate_User]
	@Username NVARCHAR(20),
	@Password NVARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @UserId INT, @LastLoginDate DATETIME
	
	SELECT @UserId = UserId, @LastLoginDate = LastLoginDate 
	FROM Users WHERE Username = @Username AND [Password] = @Password
	
	IF @UserId IS NOT NULL
	BEGIN
		IF NOT EXISTS(SELECT UserId FROM UserActivation WHERE UserId = @UserId)
		BEGIN
			UPDATE Users
			SET LastLoginDate =  GETDATE()
			WHERE UserId = @UserId
			SELECT @UserId [UserId] -- User Valid
		END
		ELSE
		BEGIN
			SELECT -2 -- User not activated.
		END
	END
	ELSE
	BEGIN
		SELECT -1 -- User invalid.
	END
END
GO
USE [LoginDB]
GO

/****** Object:  Table [dbo].[Roles]    Script Date: 07/19/2017 13:48:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Roles](
	[RoleId] [int] NOT NULL,
	[RoleName] [varchar](20) NOT NULL,
 CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


ALTER TABLE Users
ADD RoleId INT
GO

ALTER TABLE Users
ADD CONSTRAINT FK_Users_Roles
FOREIGN KEY (RoleId) REFERENCES Roles(RoleId)

GO
INSERT INTO Roles
SELECT 1, 'Administrator'
UNION ALL
SELECT 2, 'User'
GO
TRUNCATE TABLE Users
GO
INSERT INTO Users
SELECT 'Admin', '12345', 'Admin@admin.com', GETDATE(), NULL, 1
UNION ALL
SELECT 'Kailash', 'Soni', 'User@user.com', GETDATE(), NULL, 2
GO

--[Validate_User] 'Kailash', 'Soni'
ALTER  PROCEDURE [dbo].[Validate_User]
	@Username NVARCHAR(20),
	@Password NVARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @UserId INT, @LastLoginDate DATETIME, @RoleId INT
	
	SELECT @UserId = UserId, @LastLoginDate = LastLoginDate, @RoleId = RoleId 
	FROM Users WHERE Username = @Username AND [Password] = @Password
	
	IF @UserId IS NOT NULL
	BEGIN
		IF NOT EXISTS(SELECT UserId FROM UserActivation WHERE UserId = @UserId)
		BEGIN
			UPDATE Users
			SET LastLoginDate =  GETDATE()
			WHERE UserId = @UserId
			
			SELECT @UserId [UserId], 
					(SELECT RoleName FROM Roles 
					 WHERE RoleId = @RoleId) [Roles] -- User Valid
		END
		ELSE
		BEGIN
			SELECT -2 [UserId], '' [Roles]-- User not activated.
		END
	END
	ELSE
	BEGIN
		SELECT -1 [UserId], '' [Roles] -- User invalid.
	END
END

