#!/bin/bash
# WSL2 から Windows のトースト通知を出す

INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | jq -r '.message // "通知があります"')

PSCMD='$null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
$null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]
$xml = @"
<toast scenario="reminder">
  <visual>
    <binding template="ToastGeneric">
      <text>Claude Code</text>
      <text>__MESSAGE__</text>
    </binding>
  </visual>
  <actions>
    <action content="OK" arguments="dismiss" activationType="system"/>
  </actions>
</toast>
"@
$doc = [Windows.Data.Xml.Dom.XmlDocument]::new()
$doc.LoadXml($xml)
$notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Microsoft.Windows.Explorer")
$notifier.Show([Windows.UI.Notifications.ToastNotification]::new($doc))'

PSCMD="${PSCMD/__MESSAGE__/$MESSAGE}"
powershell.exe -NoProfile -Command "$PSCMD" </dev/null &>/dev/null &

exit 0
