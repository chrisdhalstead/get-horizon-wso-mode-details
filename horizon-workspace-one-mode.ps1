
<#
.SYNOPSIS
Get Horizon Workspace ONE Mode Details

.NOTES
  Version:        1.0
  Author:         Chris Halstead - chalstead@vmware.com
                 
  Purpose/Change: Initial script development

  This script requires Horizon 7 PowerCLI - https://blogs.vmware.com/euc/2020/01/vmware-horizon-7-powercli.html

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
  VMWARE,INC. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 #>

#----------------------------------------------------------[Declarations]----------------------------------------------------------
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework
[System.Windows.Forms.Application]::EnableVisualStyles()
import-module vmware.powercli
#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function LogintoHorizon {

#Capture Login Information
$script:HorizonServer = Read-Host -Prompt 'Enter the Horizon Connection Server Name'
$Username = Read-Host -Prompt 'Enter the Username'
$Password = Read-Host -Prompt 'Enter the Password' -AsSecureString
$domain = Read-Host -Prompt 'Enter the Horizon Domain'

#Convert Password
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

try {
    
    $script:hvServer = Connect-HVServer -Server $horizonserver -User $username -Password $UnsecurePassword -Domain $domain
    $script:hvServices = $hvServer.ExtensionData
    $script:cs = $script:hvServices.connectionserver.ConnectionServer_List()[0].general.name
    $script:csid = $script:hvServices.connectionserver.ConnectionServer_List()[0].id

    }

catch {
  Write-Host "An error occurred when logging on $_"
  break
}

write-host "Successfully Logged In"

} 

Function GetSAMLData {

   
        if ([string]::IsNullOrEmpty($hvserver))
        {
           write-host "You are not logged into Horizon"
            break   
           
        }
    
                
        try {
                      
        $cssamldata = $hvservices.ConnectionServer.ConnectionServer_Get($csid)

        $cssamldata | Format-table -AutoSize -Property @{Name = 'Workspace ONE Mode Enabled'; Expression = {$_.Authentication.SamlConfig.WorkspaceONEData.WorkspaceOneModeEnabled}},@{Name = 'Workspace ONE Host Name'; Expression = {$_.Authentication.SamlConfig.WorkspaceONEData.WorkspaceOneHostName}},@{Name = 'Block Clients That Do Not Support WS1 Mode'; Expression = {$_.Authentication.SamlConfig.WorkspaceONEData.WorkspaceOneBlockOldClients}}
                   
}

  catch {
          Write-Host "An error occurred when getting SAML Data $_"
          break 
        }
        
     
} 

function Show-Menu
  {
    param (
          [string]$Title = 'VMware Horizon Get Workspace ONE Mode Details'
          )
       Clear-Host
       Write-Host "================ $Title ================"
             
       Write-Host "Press '1' to Login to Horizon"
       Write-Host "Press '2' to Return Workspace ONE Mode Details"
       Write-Host "Press 'Q' to quit."
         }

do
 {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    
    '1' {  

         LogintoHorizon
    } 
    
    '2' {
   
      GetSAMLData

    }
    
    }
    pause
 }
 
 until ($selection -eq 'q')


