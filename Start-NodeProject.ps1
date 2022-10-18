$currentLocationFolders = Get-ChildItem -Path $pwd -Directory
function Show-Form {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Inicializar un nuevo proyecto de Node.js con Github"
    $form.Size = New-Object System.Drawing.Size(500, 160)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedSingle"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.TopMost = $true
    
    $labelName = New-Object System.Windows.Forms.Label
    $labelName.Text = "Project name:"
    $labelName.Location = New-Object System.Drawing.Point(10, 10)
    $labelName.Size = New-Object System.Drawing.Size(100, 20)
    $form.Controls.Add($labelName)
    
    $textboxName = New-Object System.Windows.Forms.TextBox
    $textboxName.Location = New-Object System.Drawing.Point(120, 10)
    $textboxName.Size = New-Object System.Drawing.Size(150, 20)
    $form.Controls.Add($textboxName)
    
    $labelCategory = New-Object System.Windows.Forms.Label
    $labelCategory.Text = "Project category:"
    $labelCategory.Location = New-Object System.Drawing.Point(10, 30)
    $labelCategory.Size = New-Object System.Drawing.Size(100, 20)
    $form.Controls.Add($labelCategory)
    
    $combobox = New-Object System.Windows.Forms.ComboBox
    $combobox.Location = New-Object System.Drawing.Point(120, 30)
    $combobox.Size = New-Object System.Drawing.Size(150, 20)
    $combobox.DropDownStyle = "DropDownList"
    $currentLocationFolders | ForEach-Object { $combobox.Items.Add($_.Name) }
    $combobox.Items.Add("New category")
    $form.Controls.Add($combobox)

    $labelGithub = New-Object System.Windows.Forms.Label
    $labelGithub.Text = "Github https:"
    $labelGithub.Location = New-Object System.Drawing.Point(10, 50)
    $labelGithub.Size = New-Object System.Drawing.Size(100, 20)
    $form.Controls.Add($labelGithub)

    $textboxGithub = New-Object System.Windows.Forms.TextBox
    $textboxGithub.Location = New-Object System.Drawing.Point(120, 50)
    $textboxGithub.Size = New-Object System.Drawing.Size(350, 20)
    $form.Controls.Add($textboxGithub)
    
    $button = New-Object System.Windows.Forms.Button
    $button.Text = "Create!"
    $button.Location = New-Object System.Drawing.Point(200, 80)
    $button.Size = New-Object System.Drawing.Size(100, 30)
    $button.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $button
    $form.Controls.Add($button)

    $result = $form.ShowDialog()
    
    if ($result -eq "OK") {
        $projectName = $textboxName.Text
        $projectCategory = $combobox.Text
        $projectGithub = $textboxGithub.Text
        return [PSCustomObject]@{
            ProjectName     = $projectName
            ProjectCategory = $projectCategory
            Github          = $projectGithub
        }
    }
    else {
        $form.Dispose()
        return $null
    }
}
function New-ProjectCategory {
    $categoryName = Read-Host "Nombre de la nueva categoría"
    $categoryPath = Join-Path $pwd $categoryName
    if (Test-Path $categoryPath) {
        Write-Warning "La categoría '$categoryName' ya existe"
        return $categoryName
    }
    else {
        New-Item -ItemType Directory -Path $categoryPath
        Write-Host "Categoría '$categoryName' creada"
        return $categoryName
    }
}
function Start-Node {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$projectPath,
        [Parameter(Mandatory = $true)]
        [string]$projectName,
        [Parameter(Mandatory = $false)]
        [string]$Github
    )
    Set-Location $projectPath
    Write-Host "Iniciando proyecto"
    Write-Output "# $ProjectName" | Out-File README.md
    npm init -y
    git init
    git add .
    git commit -m "Initial commit"
    git branch -M main
    if ($Github) {
        git remote add origin $Github
        git push -u origin main
    }
    else {
        Write-Host "No se ha especificado un repositorio remoto"
    }
    code .

}
$projectOptions = Show-Form
if ($projectOptions) {
    if ($projectOptions.ProjectCategory -eq "Nueva categoría") {
        $projectOptions.ProjectCategory = New-ProjectCategory
    }
    else {
        $projectPath = "$pwd\$($projectOptions.ProjectCategory)\$($projectOptions.ProjectName)"
        if (Test-Path $projectPath) {
            Write-Warning "El proyecto $projectOptions.ProjectName ya existe"
            Exit 110
        }
        else {
            New-Item -ItemType Directory -Path $projectPath
            Write-Host "Proyecto $projectOptions.ProjectName creado"
            Start-Node -projectPath $projectPath -Github $projectOptions.Github -projectName $projectOptions.ProjectName
        }
    }
}
pause
Exit 100