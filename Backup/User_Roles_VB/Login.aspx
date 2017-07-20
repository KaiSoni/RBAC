<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site1.Master" CodeBehind="Login.aspx.vb" Inherits="UserLogin_VB.Login" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<asp:Login ID="Login1" runat="server" OnAuthenticate="ValidateUser">
    </asp:Login>
    <hr />
    Username: Admin<br />
    Password: 12345<br />
    Role: Administrator<br />
    <br /><br />
    Username: Mudassar<br />
    Password: 12345<br />
    Role: User
</asp:Content>
