<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site1.Master" CodeBehind="Login.aspx.vb" Inherits="UserLogin_VB.Login" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<asp:Login ID="Login1" runat="server" OnAuthenticate="ValidateUser">
    </asp:Login>Administrator<br />
</asp:Content>
