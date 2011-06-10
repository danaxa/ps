[System.Reflection.Assembly]::LoadFrom("C:\s\t\Build\bin\Cint.dll") > $null
[System.Reflection.Assembly]::LoadFrom("C:\s\t\Build\bin\Cint.Cpx.dll") > $null

$dateStrategy = new-object Cint.Sampling.Access.DataAccess.Invoicing.InvoiceDatesStrategy
$dataContext = new-object Cint.Cpx.DatabaseMapping.CpxDataContextAdapter "Initial Catalog=PanelManagement;Data Source=sql;User ID=AppUserSql;Password=;"
$invoiceRepository = new-object Cint.Cpx.DatabaseMapping.InvoiceRepository $dataContext

$blobService = new-object Cint.Cpx.Core.Invoicing.Blob.PanelOwnerInvoiceBlobService $dataContext, $dateStrategy 

function generate-panelownerinvoices($date) {
    $invoiceRepository.ListPanelOwnerInvoicesToBlob($date) | % {
        $viewResult = $blobService.GeneratePanelOwnerInvoice($_.Company.Company_ID, $_.InvoiceDate)
        $viewResult.Invoice > ".\output\blobs\$($_.Company.Company_ID)_$($_.InvoiceDate.ToBinary()).html"  
     }
    trap { write-host $_ } 
}

function verify-panelownerinvoices($date) {
    $invoiceRepository.ListPanelOwnerInvoicesToBlob($date) | % {
        $viewResult = $blobService.GeneratePanelOwnerInvoice($_.Company.Company_ID, $_.InvoiceDate)
        $file = ".\output\blobs\$($_.Company.Company_ID)_$($_.InvoiceDate.ToBinary()).html"
        $oldInvoice = $(cat $file)
        if ($viewResult.Invoice -ne $oldInvoice) {
            throw "mismatch in $file"
        }        
     }
    trap { write-host $_ } 
}
