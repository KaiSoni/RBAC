Imports System.Data.SqlClient

Public Class Login
    Inherits System.Web.UI.Page
    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Me.IsPostBack Then
            If Me.Page.User.Identity.IsAuthenticated Then
                FormsAuthentication.SignOut()
                Response.Redirect("~/Login.aspx")
            End If
        End If
    End Sub

    Protected Sub ValidateUser(sender As Object, e As EventArgs)
        Dim userId As Integer = 0
        Dim roles As String = String.Empty
        Dim constr As String = ConfigurationManager.ConnectionStrings("constr").ConnectionString
        Using con As New SqlConnection(constr)
            Using cmd As New SqlCommand("Validate_User")
                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.AddWithValue("@Username", Login1.UserName)
                cmd.Parameters.AddWithValue("@Password", Login1.Password)
                cmd.Connection = con
                con.Open()
                Dim reader As SqlDataReader = cmd.ExecuteReader()
                reader.Read()
                userId = Convert.ToInt32(reader("UserId"))
                roles = reader("Roles").ToString()
                con.Close()
            End Using
            Select Case userId
                Case -1
                    Login1.FailureText = "Username and/or password is incorrect."
                    Exit Select
                Case -2
                    Login1.FailureText = "Account has not been activated."
                    Exit Select
                Case Else
                    Dim ticket As New FormsAuthenticationTicket(1, Login1.UserName, DateTime.Now, DateTime.Now.AddMinutes(2880), Login1.RememberMeSet, roles, _
                     FormsAuthentication.FormsCookiePath)
                    Dim hash As String = FormsAuthentication.Encrypt(ticket)
                    Dim cookie As New HttpCookie(FormsAuthentication.FormsCookieName, hash)

                    If ticket.IsPersistent Then
                        cookie.Expires = ticket.Expiration
                    End If
                    Response.Cookies.Add(cookie)
                    Response.Redirect(FormsAuthentication.GetRedirectUrl(Login1.UserName, Login1.RememberMeSet))
                    Exit Select
            End Select
        End Using
    End Sub
End Class
