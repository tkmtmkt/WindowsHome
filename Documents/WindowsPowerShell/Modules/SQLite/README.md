SQLite Module
=============

����
----

SQLite�p�̃A�Z���u���t�@�C�����_�E�����[�h����B

[System.Data.SQLite Download Page](http://system.data.sqlite.org/index.html/doc/trunk/www/downloads.wiki)

* sqlite-netFx40-static-binary-bundle-Win32-2010-1.0.81.0.zip
* sqlite-netFx40-static-binary-bundle-x64-2010-1.0.81.0.zip

�ȉ��̃t�@�C�����R�s�[����B

System.Data.SQLite.dll
System.Data.SQLite.Linq.dll

�R�s�[��
$HOME/Documents/WindowsPowerShell/Modules/SQLite


�g����
------

    Import-Module SQLite

    Connect-SQLite [�f�[�^�x�[�X�t�@�C��]

    Get-SQLiteData [�e�[�u��]

    Get-SQLiteData -Query "SELECT * FROM �e�[�u��"

    Disconnect-SQLite

<!-- vim: set ts=4 sw=4 et:-->
