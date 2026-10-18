if($Preset) { Apply $script:Presets[$Preset];return }
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase
[xml]$ui=@'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
 Title="Marceli Win &#xB7; Preview 0.3" Width="1270" Height="845" MinWidth="1060" MinHeight="700"
 Background="#090E1B" Foreground="#E2E8F0" WindowStartupLocation="CenterScreen" FontFamily="Segoe UI" FontSize="13">
 <Window.Resources>
  <Style x:Key="NavButton" TargetType="Button">
   <Setter Property="Foreground" Value="#9BA9C7"/><Setter Property="Background" Value="Transparent"/>
   <Setter Property="BorderThickness" Value="0"/><Setter Property="Padding" Value="16,12"/>
   <Setter Property="HorizontalContentAlignment" Value="Left"/><Setter Property="Cursor" Value="Hand"/>
   <Setter Property="Margin" Value="11,2"/><Setter Property="FontSize" Value="14"/>
   <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border CornerRadius="11" Background="{TemplateBinding Background}" Padding="{TemplateBinding Padding}"><ContentPresenter HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" VerticalAlignment="Center"/></Border></ControlTemplate></Setter.Value></Setter>
   <Style.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#263451"/><Setter Property="Foreground" Value="#F8FAFC"/></Trigger></Style.Triggers>
  </Style>
  <Style x:Key="ActionButton" TargetType="Button">
   <Setter Property="Background" Value="#273563"/><Setter Property="Foreground" Value="#F1F5F9"/>
   <Setter Property="BorderThickness" Value="0"/><Setter Property="Padding" Value="17,11"/>
   <Setter Property="Margin" Value="4"/><Setter Property="FontSize" Value="13"/>
   <Setter Property="Cursor" Value="Hand"/>
   <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border CornerRadius="11" Background="{TemplateBinding Background}" Padding="{TemplateBinding Padding}"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border></ControlTemplate></Setter.Value></Setter>
   <Style.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#4F46E5"/></Trigger></Style.Triggers>
  </Style>
  <Style x:Key="GlassCard" TargetType="Border"><Setter Property="Background" Value="#202B45"/><Setter Property="CornerRadius" Value="18"/><Setter Property="Padding" Value="18"/><Setter Property="Margin" Value="5"/></Style>
  <Style x:Key="SectionTitle" TargetType="TextBlock"><Setter Property="FontSize" Value="24"/><Setter Property="FontWeight" Value="SemiBold"/><Setter Property="Foreground" Value="#F8FAFC"/></Style>
  <Style TargetType="TextBlock"><Setter Property="Foreground" Value="#E2E8F0"/></Style>
  <Style TargetType="CheckBox"><Setter Property="Foreground" Value="#E2E8F0"/><Setter Property="Margin" Value="7"/></Style>
 </Window.Resources>
 <Grid>
  <Grid.ColumnDefinitions><ColumnDefinition Width="242"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
  <Border Grid.Column="0" Background="#10192C" BorderBrush="#1F304D" BorderThickness="0,0,1,0">
   <DockPanel>
    <StackPanel DockPanel.Dock="Top" Margin="20,29,10,30">
     <StackPanel Orientation="Horizontal"><TextBlock Text="&#x25C8;" Foreground="#A5B4FC" FontSize="35" VerticalAlignment="Center"/><StackPanel Margin="10,0,0,0"><TextBlock Text="MARCELI" FontSize="20" FontWeight="Bold"/><TextBlock Text="WIN / TOOLKIT" Foreground="#A5B4FC" FontSize="11" FontWeight="SemiBold"/></StackPanel></StackPanel>
     <Border Background="#233452" CornerRadius="12" Padding="10,6" HorizontalAlignment="Left" Margin="0,17,0,0"><TextBlock Text="PREVIEW 0.3  &#xB7;  OPEN SOURCE" FontSize="10" Foreground="#BFC8E8"/></Border>
    </StackPanel>
    <StackPanel DockPanel.Dock="Bottom" Margin="16,20">
     <Border Background="#192842" CornerRadius="13" Padding="12"><StackPanel>
      <TextBlock Text="SYSTEM MODE" FontWeight="Bold" Foreground="#A5B4FC" FontSize="10"/>
      <TextBlock Name="AdminStatus" Text="Checking Windows&#x2026;" Margin="0,6,0,0" FontSize="12"/>
      <TextBlock Text="No telemetry &#xB7; local changes" Foreground="#91A3C3" FontSize="10" Margin="0,6,0,0"/>
     </StackPanel></Border>
     <Button Name="MotionToggle" Style="{StaticResource NavButton}" Content="&#x25CC;  Motion: on" Margin="0,12,0,0"/>
    </StackPanel>
    <StackPanel Name="NavList" Margin="0,125,0,0">
     <Button Name="NavHome" Tag="Home" Style="{StaticResource NavButton}" Content="&#x2302;   Overview"/>
     <Button Name="NavApps" Tag="Apps" Style="{StaticResource NavButton}" Content="&#x25A6;   Applications"/>
     <Button Name="NavTweaks" Tag="Tweaks" Style="{StaticResource NavButton}" Content="&#x2726;   Tweaks &amp; privacy"/>
     <Button Name="NavGaming" Tag="Gaming" Style="{StaticResource NavButton}" Content="&#x25C6;   Gaming lab"/>
     <Button Name="NavNetwork" Tag="Network" Style="{StaticResource NavButton}" Content="&#x2301;   Network lab"/>
     <Button Name="NavRepair" Tag="Repair" Style="{StaticResource NavButton}" Content="&#x2692;   Repair centre"/>
     <Button Name="NavTools" Tag="Tools" Style="{StaticResource NavButton}" Content="&#x25A4;   System tools"/>
     <Button Name="NavProfiles" Tag="Profiles" Style="{StaticResource NavButton}" Content="&#x25C8;   Smart profiles"/>
     <Button Name="NavRecovery" Tag="Recovery" Style="{StaticResource NavButton}" Content="&#x21BA;   Recovery"/>
    </StackPanel>
   </DockPanel>
  </Border>
  <Grid Grid.Column="1" ClipToBounds="True">
   <Canvas IsHitTestVisible="False" Opacity="0.36">
    <Ellipse Name="BlurOne" Width="390" Height="390" Canvas.Left="360" Canvas.Top="-170" Fill="#4840BF"><Ellipse.Effect><BlurEffect Radius="95"/></Ellipse.Effect></Ellipse>
    <Ellipse Name="BlurTwo" Width="360" Height="360" Canvas.Left="670" Canvas.Top="260" Fill="#0E8193"><Ellipse.Effect><BlurEffect Radius="100"/></Ellipse.Effect></Ellipse>
    <Path Name="MorphShape" Fill="#4342C6" Opacity=".28" Canvas.Left="300" Canvas.Top="105" Stretch="None" Data="M 80,130 C 40,10 240,0 330,110 C 460,220 130,320 80,130 Z">
     <Path.Effect><BlurEffect Radius="33"/></Path.Effect>
    </Path>
   </Canvas>
   <Grid Margin="28,20,28,18">
    <Grid.RowDefinitions><RowDefinition Height="66"/><RowDefinition Height="188"/><RowDefinition Height="*"/><RowDefinition Height="136"/></Grid.RowDefinitions>
    <Grid Grid.Row="0">
     <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="246"/></Grid.ColumnDefinitions>
     <StackPanel>
      <TextBlock Name="PageHeading" FontSize="27" FontWeight="Bold" Text="Overview" Foreground="White"/>
      <TextBlock Name="PageSubheading" FontSize="12" Foreground="#94A3B8" Text="Personal Windows control center"/>
     </StackPanel>
     <Border Grid.Column="1" Background="#1A2740" BorderBrush="#304361" BorderThickness="1" CornerRadius="13" Height="40" VerticalAlignment="Top">
      <DockPanel Margin="12,6"><TextBlock DockPanel.Dock="Left" Text="&#x2315;" FontSize="20" Margin="0,-2,8,0" Foreground="#B7C1E9"/><TextBox Name="SearchBox" Background="Transparent" BorderThickness="0" Foreground="White" CaretBrush="White" FontSize="13" VerticalContentAlignment="Center" ToolTip="Search apps or tweaks (Ctrl+K)"/></DockPanel>
     </Border>
    </Grid>
    <Border Grid.Row="1" Background="#17243C" BorderBrush="#384A78" BorderThickness="1" CornerRadius="18" Padding="13" Margin="0,0,0,10">
     <Grid>
      <Grid.RowDefinitions><RowDefinition Height="31"/><RowDefinition Height="88"/><RowDefinition Height="*"/></Grid.RowDefinitions>
      <DockPanel Grid.Row="0">
       <TextBlock DockPanel.Dock="Left" Text="YOUR PRESETS" FontSize="16" FontWeight="Bold" Foreground="#E3E9FF"/>
       <TextBlock Text="Select a profile, then customise apps and tweaks. Nothing runs automatically." FontSize="11" Foreground="#9FABCB" VerticalAlignment="Center" HorizontalAlignment="Right"/>
      </DockPanel>
      <ScrollViewer Grid.Row="1" HorizontalScrollBarVisibility="Auto" VerticalScrollBarVisibility="Disabled" PanningMode="HorizontalOnly">
       <StackPanel Name="PresetRibbon" Orientation="Horizontal" Margin="0,2,0,0"/>
      </ScrollViewer>
      <Grid Grid.Row="2" Margin="3,5,0,0">
       <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
       <TextBlock Name="SelectionCounter" Text="Choose a preset or pick apps and tweaks manually" Foreground="#BCCCF2" VerticalAlignment="Center" FontSize="11" TextTrimming="CharacterEllipsis"/>
       <StackPanel Grid.Column="1" Orientation="Horizontal">
        <Button Name="RibbonApps" Style="{StaticResource ActionButton}" Padding="11,6" Content="Edit apps"/>
        <Button Name="RibbonTweaks" Style="{StaticResource ActionButton}" Padding="11,6" Content="Edit tweaks"/>
        <Button Name="RibbonReview" Style="{StaticResource ActionButton}" Padding="11,6" Background="#4D45A0" Content="Review setup"/>
        <Button Name="RibbonClear" Style="{StaticResource ActionButton}" Padding="11,6" Content="Clear"/>
       </StackPanel>
      </Grid>
     </Grid>
    </Border>
    <ScrollViewer Grid.Row="2" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
     <Grid Name="ContentGrid">
      <StackPanel Name="PageHome" Margin="0,8,12,12">
       <Border CornerRadius="22" Padding="26" Background="#30276A" BorderBrush="#5E5AA8" BorderThickness="1" Margin="0,4,0,15">
        <StackPanel><TextBlock Text="WELCOME TO YOUR WINDOWS" Foreground="#BFC9FF" FontSize="11" FontWeight="Bold"/>
         <TextBlock Text="Make your PC feel yours." FontSize="30" FontWeight="Bold" Foreground="White" Margin="0,8,0,4"/>
         <TextBlock Text="One dashboard. Complete visibility. Deliberate changes." FontSize="14" Foreground="#D3D8F0"/>
         <StackPanel Orientation="Horizontal" Margin="0,18,0,0"><Button Name="HomeApps" Style="{StaticResource ActionButton}" Content="Browse apps  &#x2192;"/><Button Name="HomeScan" Style="{StaticResource ActionButton}" Content="System diagnostics  &#x2192;"/><Button Name="HomeReport" Style="{StaticResource ActionButton}" Content="Export report  &#x2197;"/></StackPanel>
        </StackPanel>
       </Border>
       <TextBlock Text="YOUR MACHINE" Style="{StaticResource SectionTitle}" Margin="5,5,0,8"/>
       <Border Style="{StaticResource GlassCard}"><StackPanel><TextBlock Name="SysInfo" TextWrapping="Wrap" LineHeight="28" FontSize="14"/><Button Name="Refresh" Style="{StaticResource ActionButton}" Content="&#x21BB;  Refresh metrics" HorizontalAlignment="Left" Margin="0,14,0,0"/></StackPanel></Border>
       <TextBlock Text="QUICK ACCESS" Style="{StaticResource SectionTitle}" Margin="5,22,0,6"/>
       <WrapPanel Name="QuickPanel"/>
      </StackPanel>
      <StackPanel Name="PageApps" Visibility="Collapsed" Margin="0,8,12,12">
       <TextBlock Text="Find your apps. Install only what you want." Foreground="#9DACCD" FontSize="14" Margin="5,2,0,14"/>
       <Border Style="{StaticResource GlassCard}"><DockPanel>
        <StackPanel DockPanel.Dock="Bottom" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,12,0,0"><Button Name="SelectAllApps" Style="{StaticResource ActionButton}" Content="Select visible"/><Button Name="ClearApps" Style="{StaticResource ActionButton}" Content="Clear"/><Button Name="Install" Style="{StaticResource ActionButton}" Content="Install selected  &#x2192;"/></StackPanel>
        <WrapPanel Name="AppsPanel"/>
       </DockPanel></Border>
       <TextBlock Name="AppCount" Foreground="#9DACCD" Margin="10"/>
      </StackPanel>
      <StackPanel Name="PageTweaks" Visibility="Collapsed" Margin="0,8,12,12">
       <TextBlock Text="Individual settings. Understand them, preview them, undo them." Foreground="#9DACCD" FontSize="14" Margin="5,2,0,14"/>
       <Border Style="{StaticResource GlassCard}"><DockPanel>
        <StackPanel DockPanel.Dock="Bottom" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,14,0,0"><Button Name="Preview" Style="{StaticResource ActionButton}" Content="Preview"/><Button Name="Apply" Style="{StaticResource ActionButton}" Content="Apply selected  &#x2192;"/></StackPanel>
        <WrapPanel Name="TweaksPanel"/>
       </DockPanel></Border>
       <TextBlock Name="TweakCount" Foreground="#9DACCD" Margin="10"/>
      </StackPanel>
      <StackPanel Name="PageGaming" Visibility="Collapsed" Margin="0,8,12,12">
       <Border CornerRadius="18" Background="#26265D" Padding="20" Margin="0,0,0,12"><StackPanel><TextBlock Text="GAME LAB" Foreground="#A5B4FC" FontWeight="Bold"/><TextBlock Text="Gaming, without risky debloat scripts." FontSize="23" FontWeight="Bold" Margin="0,9,0,3"/><TextBlock Text="Game Mode, captures, graphics, HDR, audio and DirectX tools &#x2014; no anti-cheat tampering." Foreground="#B9C3DA" TextWrapping="Wrap"/><Button Name="GamingPreset" Style="{StaticResource ActionButton}" HorizontalAlignment="Left" Content="Preview Gaming profile" Margin="0,15,0,0"/></StackPanel></Border>
       <WrapPanel Name="GamingPanel"/>
      </StackPanel>
      <StackPanel Name="PageNetwork" Visibility="Collapsed" Margin="0,8,12,12">
       <TextBlock Text="Network visibility &amp; troubleshooting" FontSize="21" FontWeight="Bold" Margin="4,0,0,8"/>
       <TextBlock Text="View connections, routes, DNS and adapter settings. Diagnostics use standard Windows tools." Foreground="#A3B2CE" TextWrapping="Wrap" Margin="4,0,0,13"/>
       <WrapPanel Name="NetworkPanel"/>
      </StackPanel>
      <StackPanel Name="PageRepair" Visibility="Collapsed" Margin="0,8,12,12">
       <TextBlock Text="Recovery begins with understanding the issue." FontSize="21" FontWeight="Bold" Margin="4,0,0,8"/>
       <TextBlock Text="DISM, SFC, disk checks, package updates and built-in Windows troubleshooting. System changes require confirmation." Foreground="#A3B2CE" TextWrapping="Wrap" Margin="4,0,0,13"/>
       <WrapPanel Name="RepairPanel"/>
      </StackPanel>
      <StackPanel Name="PageTools" Visibility="Collapsed" Margin="0,8,12,12">
       <TextBlock Text="Native Windows control surfaces" FontSize="21" FontWeight="Bold" Margin="4,0,0,8"/>
       <TextBlock Text="Use familiar Microsoft tools instead of hidden registry hacks." Foreground="#A3B2CE" Margin="4,0,0,13"/>
       <WrapPanel Name="ToolsPanel"/>
      </StackPanel>
      <StackPanel Name="PageProfiles" Visibility="Collapsed" Margin="0,8,12,12">
       <TextBlock Text="Build your own setup." FontSize="24" FontWeight="Bold" Margin="4,0,0,9"/>
       <TextBlock Text="Click any preset in the large bar above, then adjust individual apps and tweaks. Your choices are not executed until you confirm." Foreground="#A4B4D0" FontSize="13" TextWrapping="Wrap" Margin="4,0,8,16"/>
       <Border Background="#242858" CornerRadius="17" Padding="18" Margin="0,0,0,12">
        <StackPanel>
         <TextBlock Name="ProfileName" Text="Custom setup" FontSize="21" Foreground="#E8ECFF" FontWeight="Bold"/>
         <TextBlock Name="ProfileDescription" TextWrapping="Wrap" Foreground="#B2C0E6" Margin="0,4,0,14"/>
         <StackPanel Orientation="Horizontal">
          <Button Name="ProfileEditApps" Style="{StaticResource ActionButton}" Content="Choose apps"/>
          <Button Name="ProfileEditTweaks" Style="{StaticResource ActionButton}" Content="Choose tweaks"/>
          <Button Name="ProfilePreview" Style="{StaticResource ActionButton}" Content="Preview selection"/>
         </StackPanel>
        </StackPanel>
       </Border>
       <Border Style="{StaticResource GlassCard}">
        <StackPanel>
         <TextBlock Name="ProfileCounts" FontSize="17" FontWeight="Bold"/>
         <TextBlock Text="SELECTED APPS" Foreground="#A5B4FC" FontWeight="Bold" Margin="0,14,0,8"/>
         <TextBlock Name="SelectedAppsSummary" Foreground="#CBD5EB" TextWrapping="Wrap"/>
         <TextBlock Text="SELECTED TWEAKS" Foreground="#A5B4FC" FontWeight="Bold" Margin="0,18,0,8"/>
         <TextBlock Name="SelectedTweaksSummary" Foreground="#CBD5EB" TextWrapping="Wrap"/>
        </StackPanel>
       </Border>
       <Border Background="#242A48" CornerRadius="16" Padding="18" Margin="5,13,5,0">
        <StackPanel>
         <TextBlock Text="READY WHEN YOU ARE" Foreground="#B4C2FF" FontWeight="Bold"/>
         <TextBlock Text="These two steps are deliberately separate and each asks for confirmation. Presets never install apps or modify settings by themselves." Foreground="#BECBE2" TextWrapping="Wrap" Margin="0,9,0,13"/>
         <WrapPanel>
          <Button Name="ProfileInstallApps" Style="{StaticResource ActionButton}" Content="Install selected apps"/>
          <Button Name="ProfileApplyTweaks" Style="{StaticResource ActionButton}" Background="#5B51A8" Content="Apply selected tweaks"/>
         </WrapPanel>
        </StackPanel>
       </Border>
      </StackPanel>
      <StackPanel Name="PageRecovery" Visibility="Collapsed" Margin="0,8,12,12">
       <TextBlock Text="Recover, export &amp; inspect." FontSize="21" FontWeight="Bold" Margin="4,0,0,14"/>
       <WrapPanel>
        <Border Style="{StaticResource GlassCard}" Width="330"><StackPanel><TextBlock Text="Undo last tweak batch" FontSize="17" FontWeight="Bold"/><TextBlock Text="Previous registry values are restored. Archived older batches stay local." TextWrapping="Wrap" Foreground="#9FAEC8" Margin="0,8,0,12"/><Button Name="Undo" Style="{StaticResource ActionButton}" Content="&#x21BA;  Undo last batch"/></StackPanel></Border>
        <Border Style="{StaticResource GlassCard}" Width="330"><StackPanel><TextBlock Text="Windows restore point" FontSize="17" FontWeight="Bold"/><TextBlock Text="Ask Windows to create a restore point. Requires admin and System Protection." TextWrapping="Wrap" Foreground="#9FAEC8" Margin="0,8,0,12"/><Button Name="RestorePoint" Style="{StaticResource ActionButton}" Content="&#xFF0B;  Create checkpoint"/></StackPanel></Border>
        <Border Style="{StaticResource GlassCard}" Width="330"><StackPanel><TextBlock Text="Save your setup" FontSize="17" FontWeight="Bold"/><TextBlock Text="Share only the selected apps and tweaks. Import never applies them automatically." TextWrapping="Wrap" Foreground="#9FAEC8" Margin="0,8,0,12"/><StackPanel Orientation="Horizontal"><Button Name="ExportProfile" Style="{StaticResource ActionButton}" Content="Export"/><Button Name="ImportProfile" Style="{StaticResource ActionButton}" Content="Import"/></StackPanel></StackPanel></Border>
        <Border Style="{StaticResource GlassCard}" Width="330"><StackPanel><TextBlock Text="Diagnostics and logs" FontSize="17" FontWeight="Bold"/><TextBlock Text="Export a system summary or inspect local log and archived backups." TextWrapping="Wrap" Foreground="#9FAEC8" Margin="0,8,0,12"/><StackPanel Orientation="Horizontal"><Button Name="ExportReport" Style="{StaticResource ActionButton}" Content="Report"/><Button Name="OpenData" Style="{StaticResource ActionButton}" Content="Data folder"/></StackPanel></StackPanel></Border>
       </WrapPanel>
      </StackPanel>
     </Grid>
    </ScrollViewer>
    <Grid Grid.Row="3" Margin="0,7,0,0">
     <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
     <Border Name="QueueBanner" Grid.Row="0" Background="#252F51" BorderBrush="#55639B" BorderThickness="1" CornerRadius="12" Padding="8" Visibility="Collapsed" Margin="0,0,0,7">
      <Grid>
       <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
       <StackPanel>
        <TextBlock Name="QueueStatus" Text="Ready" Foreground="#E6EDFF" FontSize="11" TextTrimming="CharacterEllipsis"/>
        <ProgressBar Name="QueueProgress" Height="5" Margin="0,5,5,0" Foreground="#9184FE" Background="#17233B" Value="0"/>
       </StackPanel>
       <Button Name="QueueStop" Grid.Column="1" Content="Stop after current" Padding="11,5" Style="{StaticResource ActionButton}" ToolTip="Skips pending commands; never forcibly kills an active installer"/>
      </Grid>
     </Border>
     <Border Grid.Row="1" Background="#131E32" CornerRadius="14" BorderBrush="#2A395A" BorderThickness="1" Padding="13" Margin="0,12,0,0">
     <DockPanel><DockPanel DockPanel.Dock="Top" Margin="2,0,0,8"><TextBlock Text="&#x25CF;  LIVE LOCAL ACTIVITY" FontSize="11" FontWeight="Bold" Foreground="#8FDBDA"/><TextBlock Name="StatusText" Text="Ready" DockPanel.Dock="Right" HorizontalAlignment="Right" Foreground="#8EA1C5" FontSize="11"/></DockPanel>
      <TextBox Name="LogText" Background="#0D1525" Foreground="#C0F2E5" BorderThickness="0" FontFamily="Consolas" FontSize="11" IsReadOnly="True" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto"/>
     </DockPanel>
     </Border>
    </Grid>
   </Grid>
  </Grid>
 </Grid>
</Window>
'@
$script:Window=[Windows.Markup.XamlReader]::Load([Xml.XmlNodeReader]::new($ui))
$script:Window.Dispatcher.Add_UnhandledException({
 param($sender,$eventArgs)
 $msg=if($eventArgs.Exception){$eventArgs.Exception.Message}else{'Unknown UI exception'}
 try {Log ('UNEXPECTED UI ERROR: '+$msg)}catch{}
 [Windows.MessageBox]::Show('Marceli Win could not complete a UI action.'+[Environment]::NewLine+$msg+
  [Environment]::NewLine+'Review the local activity log for details.','Marceli Win - Error')|Out-Null
 $eventArgs.Handled=$true
})
function El([string]$id) { $script:Window.FindName($id) }
$script:QueueTimer=[Windows.Threading.DispatcherTimer]::new()
$script:QueueTimer.Interval=[TimeSpan]::FromMilliseconds(300)
$script:QueueTimer.Add_Tick({PollCommandQueue})
(El 'QueueStop').Add_Click({
 if($script:ActiveCommand -or $script:CommandQueue.Count -gt 0){
  $script:CancelAfterCurrent=$true
  Log 'Stop requested: pending commands will be skipped after the active installer exits.'
  if(!$script:ActiveCommand){PollCommandQueue}
 }
})
$script:Window.Add_Closing({
 param($sender,$eventArgs)
 if($script:ActiveCommand -or $script:CommandQueue.Count -gt 0){
  $result=[Windows.MessageBox]::Show(
   'An operation is still running or queued. Closing the window will abandon pending tasks but will NOT terminate an active installer. Close anyway?',
   'Marceli Win - Active tasks','YesNo','Warning')
  if($result -ne 'Yes'){$eventArgs.Cancel=$true;return}
  $script:CommandQueue.Clear()
  if($script:QueueTimer.IsEnabled){$script:QueueTimer.Stop()}
  if($script:ActiveCommand){
   Log ('Detached from running operation: '+$script:ActiveCommand.Label+'. The external process can continue.')
   $script:ActiveCommand.Process.Dispose()
   $script:ActiveCommand=$null
  }
 }
})
$script:LogBox=El 'LogText'
$script:MotionEnabled=$true
$script:MotionTargets=@()
$script:CurrentPage='Home'
$script:PageNames=@('Home','Apps','Tweaks','Gaming','Network','Repair','Tools','Profiles','Recovery')
$script:Descriptions=@{Home='Your personal Windows command centre';Apps='Browse curated WinGet applications';Tweaks='Reversible Windows preferences';Gaming='Performance and gaming controls';Network='Understand your connections';Repair='Repair with built-in Windows tools';Tools='Everything in one place';Profiles='Safe, focused presets';Recovery='Undo, backup and export'}
function Page([string]$id) {
 if ($script:PageNames -notcontains $id) {return}
 foreach($name in $script:PageNames) {
  $panel=El ('Page'+$name)
  $button=El ('Nav'+$name)
  if($id -eq $name) {
   $panel.Visibility='Visible'
   $button.Background=[Windows.Media.BrushConverter]::new().ConvertFromString('#36356D')
   $button.Foreground=[Windows.Media.Brushes]::White
   if($script:MotionEnabled) {
    $anim=[Windows.Media.Animation.DoubleAnimation]::new()
    $anim.From=0.1;$anim.To=1;$anim.Duration=[Windows.Duration]::new([TimeSpan]::FromMilliseconds(320))
    $panel.BeginAnimation([Windows.UIElement]::OpacityProperty,$anim)
   } else {$panel.Opacity=1}
  } else {
   $panel.Visibility='Collapsed'
   $button.ClearValue([Windows.Controls.Control]::BackgroundProperty)
   $button.ClearValue([Windows.Controls.Control]::ForegroundProperty)
  }
 }
 $script:CurrentPage=$id
 (El 'PageHeading').Text=$id
 (El 'PageSubheading').Text=$script:Descriptions[$id]
}
function AnimateMorph {
 $blob=El 'MorphShape'
 $geometry=[Windows.Media.PathGeometry]::CreateFromGeometry($blob.Data)
 if ($geometry.Figures.Count -lt 1 -or $geometry.Figures[0].Segments.Count -lt 1) { throw 'Morph path has no editable segments.' }
 $blob.Data=$geometry
 $seg=$geometry.Figures[0].Segments[0]
 $point=[Windows.Media.Animation.PointAnimation]::new()
 $point.To=[Windows.Point]::new(25,65)
 $point.Duration=[Windows.Duration]::new([TimeSpan]::FromSeconds(8))
 $point.AutoReverse=$true
 $point.RepeatBehavior=[Windows.Media.Animation.RepeatBehavior]::Forever
 $seg.BeginAnimation([Windows.Media.BezierSegment]::Point1Property,$point)
 $script:MotionTargets+=@($seg)
 foreach($name in @('BlurOne','BlurTwo')) {
  $ellipse=El $name
  $move=[Windows.Media.TranslateTransform]::new()
  $ellipse.RenderTransform=$move
  $a=[Windows.Media.Animation.DoubleAnimation]::new()
  $a.To= if($name -eq 'BlurOne'){85}else{-120}
  $a.Duration=[Windows.Duration]::new([TimeSpan]::FromSeconds(13))
  $a.AutoReverse=$true
  $a.RepeatBehavior=[Windows.Media.Animation.RepeatBehavior]::Forever
  $move.BeginAnimation([Windows.Media.TranslateTransform]::XProperty,$a)
  $script:MotionTargets+=@($move)
 }
}
function StopMorph {
 foreach($v in $script:MotionTargets) {
  if($v -is [Windows.Media.BezierSegment]) {$v.BeginAnimation([Windows.Media.BezierSegment]::Point1Property,$null)}
  elseif($v -is [Windows.Media.TranslateTransform]) {$v.BeginAnimation([Windows.Media.TranslateTransform]::XProperty,$null)}
 }
 $script:MotionTargets=@()
}
if ($SmokeTest) {
 AnimateMorph
 StopMorph
 $script:MotionEnabled=$false
} elseif ([Windows.SystemParameters]::ClientAreaAnimation -and ![Windows.SystemParameters]::HighContrast) {
 try { AnimateMorph } catch { StopMorph; $script:MotionEnabled=$false; Log ('Motion disabled: '+$_.Exception.Message) }
} else { $script:MotionEnabled=$false; (El 'MotionToggle').Content='Motion: off' }
(El 'MotionToggle').Add_Click({
 if($script:MotionEnabled){StopMorph;$script:MotionEnabled=$false;(El 'MotionToggle').Content='Motion  Motion: off'}
 else {AnimateMorph;$script:MotionEnabled=$true;(El 'MotionToggle').Content='Motion  Motion: on'}
})
foreach($name in $script:PageNames) {
 $nav=El ('Nav'+$name)
 $nav.Add_Click({param($sender,$args) Page ([string]$sender.Tag)})
}
Page 'Home'
$script:AppBoxes=@()
$script:TweakBoxes=@()
function NewCard([string]$title,[string]$detail,[string]$tag,[string]$group,[string]$target) {
 $card=[Windows.Controls.Border]::new()
 $card.Background=[Windows.Media.BrushConverter]::new().ConvertFromString('#1B2942')
 $card.BorderBrush=[Windows.Media.BrushConverter]::new().ConvertFromString('#2D4163')
 $card.BorderThickness=[Windows.Thickness]::new(1)
 $card.CornerRadius=[Windows.CornerRadius]::new(12)
 $card.Padding=[Windows.Thickness]::new(12)
 $card.Margin=[Windows.Thickness]::new(5)
 $card.Width=278
 $stack=[Windows.Controls.StackPanel]::new()
 $check=[Windows.Controls.CheckBox]::new()
 $check.Content=$title
 $check.Tag=$tag
 $check.FontWeight='SemiBold'
 $check.ToolTip=$detail
 $caption=[Windows.Controls.TextBlock]::new()
 $caption.Text=$group+'   -   '+$detail
 $caption.Foreground=[Windows.Media.BrushConverter]::new().ConvertFromString('#9CACCC')
 $caption.FontSize=11
 $caption.TextWrapping='Wrap'
 $caption.Margin=[Windows.Thickness]::new(8,4,7,0)
 [void]$stack.Children.Add($check);[void]$stack.Children.Add($caption)
 $card.Child=$stack
 [void](El $target).Children.Add($card)
 return [pscustomobject]@{Box=$card;Check=$check;Search=($title+' '+$group+' '+$detail).ToLowerInvariant()}
}
foreach($a in $script:Apps) {
 $script:AppBoxes+=@(NewCard $a.Name ('WinGet: '+$a.ID) $a.ID $a.Group 'AppsPanel')
}
foreach($t in $script:Tweaks) {
 $group=if($t.ContainsKey('Group')){$t.Group}else{'Windows'}
 $script:TweakBoxes+=@(NewCard $t.Name $t.Info $t.ID $group 'TweaksPanel')
}
function FilterCards {
 $query=(El 'SearchBox').Text.Trim().ToLowerInvariant()
 $appVisible=0;$tweakVisible=0
 foreach($a in $script:AppBoxes) {
  $show=(!$query -or $a.Search.Contains($query))
  $a.Box.Visibility=if($show){'Visible'}else{'Collapsed'}
  if($show){$appVisible++}
 }
 foreach($t in $script:TweakBoxes) {
  $show=(!$query -or $t.Search.Contains($query))
  $t.Box.Visibility=if($show){'Visible'}else{'Collapsed'}
  if($show){$tweakVisible++}
 }
 (El 'AppCount').Text=($appVisible.ToString()+' applications visible')
 (El 'TweakCount').Text=($tweakVisible.ToString()+' tweaks visible')
}
(El 'SearchBox').Add_TextChanged({FilterCards})
FilterCards
function SelectedApps { @($script:AppBoxes|Where-Object {$_.Check.IsChecked -eq $true}|ForEach-Object {[string]$_.Check.Tag}) }
function SelectedTweaks { @($script:TweakBoxes|Where-Object {$_.Check.IsChecked -eq $true}|ForEach-Object {[string]$_.Check.Tag}) }
$script:ChoosingPreset=$false
$script:CurrentPreset='Custom'
$script:PresetTiles=@{}
$script:PresetDescriptions=@{Custom='Create your own mix of apps and Windows preferences. No changes run automatically.'}
foreach($name in @($script:SetupPresets.Keys)) {$script:PresetDescriptions[$name]=$script:SetupPresets[$name].Desc}
function UpdateProfileSummary {
 $apps=@(SelectedApps)
 $tweaks=@(SelectedTweaks)
 $name=$script:CurrentPreset
 (El 'SelectionCounter').Text=($name+'  |  '+$apps.Count+' apps chosen  |  '+$tweaks.Count+' tweaks chosen')
 (El 'ProfileName').Text=($name+' setup')
 (El 'ProfileDescription').Text=$script:PresetDescriptions[$name]
 (El 'ProfileCounts').Text=($apps.Count.ToString()+' applications   /   '+$tweaks.Count.ToString()+' Windows tweaks')
 (El 'SelectedAppsSummary').Text=if($apps.Count){(@($script:Apps|Where-Object {$apps -contains $_.ID}|ForEach-Object {$_.Name}) -join '   |   ')}else{'No apps selected. Choose some from Applications.'}
 (El 'SelectedTweaksSummary').Text=if($tweaks.Count){(@($script:Tweaks|Where-Object {$tweaks -contains $_.ID}|ForEach-Object {$_.Name}) -join '   |   ')}else{'No tweaks selected. Choose some from Tweaks & privacy.'}
 foreach($id in @($script:PresetTiles.Keys)){
  $tile=$script:PresetTiles[$id]
  $tile.Background=[Windows.Media.BrushConverter]::new().ConvertFromString($(if($id -eq $name){'#5045A6'}else{'#202F4D'}))
  $tile.BorderBrush=[Windows.Media.BrushConverter]::new().ConvertFromString($(if($id -eq $name){'#A6A5FF'}else{'#394A6C'}))
 }
}
function SetSetupPreset([string]$name) {
 if($name -eq 'Custom') {
  $script:CurrentPreset='Custom'
  UpdateProfileSummary
  return
 }
 if (!$script:SetupPresets.Contains($name)) {throw ('Unknown setup preset: '+$name)}
 $appIds=@($script:SetupPresets[$name].Apps)
 $tweakIds=@($script:Presets[$name])
 $script:ChoosingPreset=$true
 try {
  foreach($a in $script:AppBoxes){$a.Check.IsChecked=($appIds -contains $a.Check.Tag)}
  foreach($t in $script:TweakBoxes){$t.Check.IsChecked=($tweakIds -contains $t.Check.Tag)}
 } finally {$script:ChoosingPreset=$false}
 $script:CurrentPreset=$name
 UpdateProfileSummary
 Log ('Selected '+$name+' profile ('+$appIds.Count+' apps, '+$tweakIds.Count+' tweaks). Nothing installed or changed.')
}
function NewPresetTile([string]$name,[string]$subtext,[string]$detail) {
 $button=[Windows.Controls.Button]::new()
 $button.Name='Tile'+$name
 $button.Tag=$name
 $button.Background=[Windows.Media.BrushConverter]::new().ConvertFromString('#202F4D')
 $button.Foreground=[Windows.Media.Brushes]::White
 $button.BorderBrush=[Windows.Media.BrushConverter]::new().ConvertFromString('#394A6C')
 $button.BorderThickness=[Windows.Thickness]::new(1)
 $button.Padding=[Windows.Thickness]::new(13,7,13,7)
 $button.Margin=[Windows.Thickness]::new(0,0,9,0)
 $button.Width=143
 $button.Height=70
 $button.Cursor=[Windows.Input.Cursors]::Hand
 $button.ToolTip=$detail
 $stack=[Windows.Controls.StackPanel]::new()
 $main=[Windows.Controls.TextBlock]::new()
 $main.Text=$name;$main.FontSize=15;$main.FontWeight='Bold'
 $secondary=[Windows.Controls.TextBlock]::new()
 $secondary.Text=$subtext;$secondary.Foreground=[Windows.Media.BrushConverter]::new().ConvertFromString('#C2C9ED')
 $secondary.FontSize=11;$secondary.Margin=[Windows.Thickness]::new(0,5,0,0)
 [void]$stack.Children.Add($main);[void]$stack.Children.Add($secondary)
 $button.Content=$stack
 $button.Add_Click({param($sender,$args) SetSetupPreset ([string]$sender.Tag)})
 [void](El 'PresetRibbon').Children.Add($button)
 $script:PresetTiles[$name]=$button
}
foreach($name in @($script:SetupPresets.Keys)) {
 $apps=@($script:SetupPresets[$name].Apps).Count
 $tweaks=@($script:Presets[$name]).Count
 NewPresetTile $name ($apps.ToString()+' apps  /  '+$tweaks.ToString()+' tweaks') $script:SetupPresets[$name].Desc
}
NewPresetTile 'Custom' 'Your own mix' 'Keep your current choices and customise freely.'
foreach($item in @($script:AppBoxes)+@($script:TweakBoxes)) {
 $item.Check.Add_Checked({
  if(!$script:ChoosingPreset){$script:CurrentPreset='Custom';UpdateProfileSummary}
 })
 $item.Check.Add_Unchecked({
  if(!$script:ChoosingPreset){$script:CurrentPreset='Custom';UpdateProfileSummary}
 })
}
UpdateProfileSummary
(El 'RibbonApps').Add_Click({Page 'Apps'})
(El 'RibbonTweaks').Add_Click({Page 'Tweaks'})
(El 'RibbonReview').Add_Click({Page 'Profiles'})
(El 'RibbonClear').Add_Click({
 $script:ChoosingPreset=$true
 try {
  foreach($a in $script:AppBoxes){$a.Check.IsChecked=$false}
  foreach($t in $script:TweakBoxes){$t.Check.IsChecked=$false}
 } finally {$script:ChoosingPreset=$false}
 $script:CurrentPreset='Custom'
 UpdateProfileSummary
 Log 'Cleared app and tweak selections. No system settings were changed.'
})
(El 'SelectAllApps').Add_Click({foreach($a in $script:AppBoxes){if($a.Box.Visibility -eq 'Visible'){$a.Check.IsChecked=$true}}})
(El 'ClearApps').Add_Click({foreach($a in $script:AppBoxes){$a.Check.IsChecked=$false}})
(El 'Preview').Add_Click({Apply (SelectedTweaks) $true})
(El 'Apply').Add_Click({Apply (SelectedTweaks)})
function InstallSelectedApps {
 $wanted=@(SelectedApps)
 $apps=@($script:Apps|Where-Object {$wanted -contains $_.ID})
 if(!$apps.Count){Log 'Select apps first.';return}
 if(!(Get-Command winget.exe -CommandType Application -ErrorAction SilentlyContinue)){
  Log 'WinGet is not installed or not in PATH. Install Microsoft App Installer first.'
  return
 }
 $message='Queue '+$apps.Count+' exact packages from the WinGet community source?'+[Environment]::NewLine+
  ($apps.Name -join ', ')+[Environment]::NewLine+
  'Installers may prompt separately for licence terms and elevation. Cancel pending tasks from the activity panel.'
 if([Windows.MessageBox]::Show($message,'Marceli Win - Confirm install','YesNo','Question') -ne 'Yes'){return}
 foreach($app in $apps){
  # Hardcoded package IDs only; exact match and source restriction avoid ambiguous installs.
  $args=@('install','--id',[string]$app.ID,'--exact','--source','winget','--accept-source-agreements')
  QueueCommand ('Install '+$app.Name) 'winget.exe' $args
 }
}
(El 'Install').Add_Click({InstallSelectedApps})
(El 'ProfileEditApps').Add_Click({Page 'Apps'})
(El 'ProfileEditTweaks').Add_Click({Page 'Tweaks'})
(El 'ProfileInstallApps').Add_Click({InstallSelectedApps})
(El 'ProfileApplyTweaks').Add_Click({Apply (SelectedTweaks)})
(El 'ProfilePreview').Add_Click({
 $apps=@(SelectedApps);$tweaks=@(SelectedTweaks)
 Log ('PREVIEW '+$script:CurrentPreset+' profile: '+$apps.Count+' apps + '+$tweaks.Count+' tweaks. No changes were made.')
 if($apps.Count){Log ('APPS: '+(@($script:Apps|Where-Object {$apps -contains $_.ID}|ForEach-Object {$_.Name}) -join ', '))}
 if($tweaks.Count){Apply $tweaks $true}
})
(El 'GamingPreset').Add_Click({SetSetupPreset 'Gaming';Page 'Profiles'})
function NewActionCard($act,[string]$target) {
 $border=[Windows.Controls.Border]::new()
 $border.Background=[Windows.Media.BrushConverter]::new().ConvertFromString('#1B2942')
 $border.BorderBrush=[Windows.Media.BrushConverter]::new().ConvertFromString('#2E4165')
 $border.BorderThickness=[Windows.Thickness]::new(1)
 $border.CornerRadius=[Windows.CornerRadius]::new(14)
 $border.Padding=[Windows.Thickness]::new(12)
 $border.Margin=[Windows.Thickness]::new(5)
 $border.Width=275
 $stack=[Windows.Controls.StackPanel]::new()
 $heading=[Windows.Controls.TextBlock]::new()
 $heading.Text=$act.Name;$heading.FontWeight='SemiBold';$heading.FontSize=14
 $desc=[Windows.Controls.TextBlock]::new()
 $desc.Text=$act.Desc
 $desc.Foreground=[Windows.Media.BrushConverter]::new().ConvertFromString('#9EAFCE')
 $desc.Margin=[Windows.Thickness]::new(0,7,0,10);$desc.TextWrapping='Wrap'
 $button=[Windows.Controls.Button]::new()
 $button.Content=if($act.Kind -eq 'open'){'Open  (open)'}else{'Review & run  > '}
 $button.Tag=$act.ID
 $button.Style=$script:Window.FindResource('ActionButton')
 $button.HorizontalAlignment='Left'
 $button.Add_Click({param($sender,$args) RunAction ([string]$sender.Tag)})
 [void]$stack.Children.Add($heading);[void]$stack.Children.Add($desc);[void]$stack.Children.Add($button)
 $border.Child=$stack
 [void](El $target).Children.Add($border)
}
foreach($act in $script:Actions) {NewActionCard $act ($act.Group+'Panel')}
foreach($id in @('taskmgr','winupdate','resource','storage')) {
 $action=$script:Actions|Where-Object {$_.ID -eq $id}|Select-Object -First 1
 if($action){NewActionCard $action 'QuickPanel'}
}
function RefreshSystem {
 try {
  $os=Get-CimInstance Win32_OperatingSystem
  $cpu=Get-CimInstance Win32_Processor|Select-Object -First 1
  $gpu=Get-CimInstance Win32_VideoController|Select-Object -First 1
  $drive=Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
  $memory=[math]::Round($os.TotalVisibleMemorySize/1MB,1)
  $free=if($drive){[math]::Round($drive.FreeSpace/1GB,1).ToString()+' GB'}else{'N/A'}
  (El 'SysInfo').Text='WINDOWS   '+$os.Caption+'  -  Build '+$os.BuildNumber+[Environment]::NewLine+
   'PROCESSOR   '+$cpu.Name+[Environment]::NewLine+
   'GRAPHICS   '+$gpu.Name+[Environment]::NewLine+
   'MEMORY   '+$memory+' GB    -    DISK C: FREE   '+$free+[Environment]::NewLine+
   'UPTIME   '+((Get-Date)-$os.LastBootUpTime).ToString('dd\.hh\:mm')+[Environment]::NewLine+
   'ADMINISTRATOR   '+(IsAdmin)
  (El 'AdminStatus').Text=if(IsAdmin){'Elevated mode'}else{'Standard user'}
 } catch {Log ('Metrics unavailable: '+$_.Exception.Message)}
}
(El 'Refresh').Add_Click({RefreshSystem})
(El 'HomeApps').Add_Click({Page 'Apps'})
(El 'HomeScan').Add_Click({Page 'Repair'})
(El 'HomeReport').Add_Click({ExportReport})
(El 'Undo').Add_Click({RestoreLast})
(El 'RestorePoint').Add_Click({MakeRestorePoint})
(El 'ExportProfile').Add_Click({ExportProfile (SelectedApps) (SelectedTweaks)})
(El 'ImportProfile').Add_Click({
 $p=LoadProfile
 if($null -eq $p){return}
 foreach($a in $script:AppBoxes){$a.Check.IsChecked=($p.Apps -contains $a.Check.Tag)}
 foreach($t in $script:TweakBoxes){$t.Check.IsChecked=($p.Tweaks -contains $t.Check.Tag)}
 $script:CurrentPreset='Custom'
 UpdateProfileSummary
 Page 'Profiles'
 Log 'Selections restored. Nothing applied automatically.'
})
(El 'ExportReport').Add_Click({ExportReport})
(El 'OpenData').Add_Click({Start-Process 'explorer.exe' -ArgumentList $script:Data})
$script:Window.Add_PreviewKeyDown({
 param($sender,$e)
 if($e.Key -eq 'K' -and ([Windows.Input.Keyboard]::Modifiers -band [Windows.Input.ModifierKeys]::Control)){
  (El 'SearchBox').Focus()|Out-Null
  if($script:CurrentPage -notin @('Apps','Tweaks')){Page 'Apps'}
  $e.Handled=$true
 }
 if($e.Key -eq 'Escape') {(El 'SearchBox').Text=''}
})
RefreshSystem
Log ('Marceli Win preview ready  -  '+$script:Apps.Count+' app entries  -  '+$script:Tweaks.Count+' tweaks  -  '+$script:Actions.Count+' system tools. No changes made.')
if($SmokeTest) {
 # The fake command has zero external side effects. Verify that the dispatcher
 # receives a process handle immediately and that the queue eventually settles.
 QueueCommand 'CI process queue smoke' 'cmd.exe' @('/c','exit','0')
 if($null -eq $script:ActiveCommand){throw 'Process queue did not start.'}
 for($i=0;$i -lt 80 -and $script:ActiveCommand;$i++){
  Start-Sleep -Milliseconds 60
  PollCommandQueue
 }
 if($script:ActiveCommand -or $script:CommandQueue.Count -gt 0){throw 'Process queue did not complete.'}
 foreach($name in $script:PageNames) {if(!(El ('Page'+$name))){throw ('Missing page '+$name)}}
 foreach($name in @($script:SetupPresets.Keys)){
  SetSetupPreset $name
  if(@(SelectedApps).Count -ne @($script:SetupPresets[$name].Apps).Count){throw ('App preset selection mismatch: '+$name)}
  if(@(SelectedTweaks).Count -ne @($script:Presets[$name]).Count){throw ('Tweak preset selection mismatch: '+$name)}
 }
 SetSetupPreset 'Developer'
 $script:AppBoxes[0].Check.IsChecked=!$script:AppBoxes[0].Check.IsChecked
 if($script:CurrentPreset -ne 'Custom'){throw 'Manual selection must switch to Custom profile'}
 if($script:PresetTiles.Count -ne 8){throw 'Preset bar is missing a preset tile'}
 StopMorph
 Write-Host 'GUI smoke test passed: WPF navigation, 8 preset bar tiles, app/tweak selection, and customisation.'
 $script:Window.Close()
 return
}
[void]$script:Window.ShowDialog()
