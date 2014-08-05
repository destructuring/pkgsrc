$NetBSD: patch-UnAlz.h,v 1.2 2014/01/09 15:54:44 jperkin Exp $

* <cstring> for memset(3) and strlen(3)
* <cstdlib> for free(3)
* Avoid ERR macro

--- UnAlz.h.orig	2007-02-10 05:55:10.000000000 +0000
+++ UnAlz.h
@@ -131,6 +131,8 @@
 #define _UNALZ_H_
 
 #include <vector>
+#include <cstring>
+#include <cstdlib>
 using namespace std;
 
 
@@ -426,6 +428,7 @@ public :
 	FileList::iterator	GetCurFileHeader() { return m_posCur; };		///<  ���� (SetCurrentFile() �� ���õ�) ���� ����
 
 public :
+#undef ERR
 	enum ERR							///< ���� �ڵ� - ���� �ʿ�..
 	{
 		ERR_NOERR,
