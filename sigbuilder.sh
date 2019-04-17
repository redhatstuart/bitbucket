#!/bin/bash

# Written by Stuart Kirk
# stuart.kirk@microsoft.com
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

clear

echo "This script provides commands to create and populate a shared image gallery from a VHD in blob storage."
echo "Not all commands may be necessary for your configuration. In addition there is no error checking on spelling, length, or validity of inputs."
echo "You must have the latest Azure Linux CLI installed, be logged in, and have your active subscription set correctly."
echo "In short:  Use at your own risk."

echo " "
echo -n "Determining your current and active Azure subscription ID..."
export AZURESUBSCRIPTIONID="`az account list -o table --query '[].{subscriptionId: id, isDefault: isDefault}' |grep -i True |cut -f1 -d' '`"
echo $AZURESUBSCRIPTIONID
echo " "

########## Image Upload to SIG Source DC

echo "Consult the source data center region availability list at: https://azure.microsoft.com/en-us/blog/announcing-the-public-preview-of-shared-image-gallery"
echo -n "Enter the source region Azure Data Center where the VM image will originate from (ex: eastus) >"
read AZUREDC
if [ -z "$AZUREDC" ]; then AZUREDC="eastus"; fi

echo " "
echo -n "Enter the name of the resource group where you want to deploy the SIG [aka the Source Region] and where the storage account will be created for the uploaded image (ex: mysourceregionrg) >"
read RGNAME
if [ -z "$RGNAME" ]; then RGNAME="mysourceregionrg"; fi

echo " "
echo -n "Enter the name of the storage account where the uploaded disk image vhd should be saved (ex: `whoami`vhdimgstorage) >"
read STORAGEACCOUNTNAME
if [ -z "$STORAGEACCOUNTNAME" ]; then STORAGEACCOUNTNAME="`whoami`vhdimgstorage"; fi

echo " "
echo -n "Enter the name of the storage container that you intend to create in blob storage (ex: vhds) >"
read CONTAINERNAME
if [ -z "$CONTAINERNAME" ]; then CONTAINERNAME="vhds"; fi

echo " "
echo -n "Enter the local full path and filename to the VHD which you are uploading to your storage account. (ex: /full/path/to/my/uploadimage.vhd) >"
read FULLPATHTOFILE
if [ -z "$FULLPATHTOFILE" ]; then FULLPATHTOFILE="/full/path/to/my/uploadimage.vhd"; fi

echo " "
echo -n "Enter the name of the VHD which you like to have SAVED in blob storage. This may be different from the image name you are uploading. (ex: myazureblobimage.vhd) >"
read NAMEOFVHD
if [ -z "$NAMEOFVHD" ]; then NAMEOFVHD="myazureblobimage.vhd"; fi

########## Create Disk Image

echo " "
echo -n "Enter the name of the disk image to be created from your image in blob storage (ex: my-goldimage-template) >"
read NAMEOFIMAGETEMPLATE
if [ -z "$NAMEOFIMAGETEMPLATE" ]; then NAMEOFIMAGETEMPLATE="my-goldimage-template"; fi

########## SIG Creation

echo " "
echo -n "Enter the name for the SIG itself (ex: MyCustomImages) >"
read SIGIMAGEGALLERYNAME
if [ -z "$SIGIMAGEGALLERYNAME" ]; then SIGIMAGEGALLERYNAME="MyCustomImages"; fi

echo " "
echo -n "Enter the name of the SIG definition (ex: GoldImage) >"
read GALLERYIMAGEDEFINITION
if [ -z "$GALLERYIMAGEDEFINITION" ]; then GALLERYIMAGEDEFINITION="GoldImage"; fi

echo " "
echo -n "Enter the version of the image (ex: 1.0.0) >"
read GALLERYIMAGEVERSION
if [ -z "$GALLERYIMAGEVERSION" ]; then GALLERYIMAGEVERSION="1.0.0"; fi

echo " "
echo -n "Enter the name of the SIG image offer (ex: WindowsServer or UbuntuServer or RHEL or SLES or something else) >"
read IMAGEOFFER
if [ -z "$IMAGEOFFER" ]; then IMAGEOFFER="RHEL"; fi

echo " "
echo -n "Enter the name of the SIG image publisher (ex: RedHat or MicrosoftWindowsServer or OpenLogic or something else) >"
read IMAGEPUBLISHER
if [ -z "$IMAGEPUBLISHER" ]; then IMAGEPUBLISHER="RedHat"; fi

echo " "
echo -n "Enter the name of the SIG image SKU (ex: 7.5 or 2016-Datacenter or 7.3 or something else) >"
read IMAGESKU
if [ -z "$IMAGESKU" ]; then IMAGESKU="7.5"; fi

echo " "
echo -n "Enter the minimum number of CPUs that should be assigned to virtual machines in this SIG image definition (ex: 2)  >"
read MINCPU
if [ -z "$MINCPU" ]; then MINCPU="2"; fi

echo " "
echo -n "Enter the maximum number of CPUs that should be assigned to virtual machines in this SIG image definition (ex: 64) >"
read MAXCPU
if [ -z "$MAXCPU" ]; then MAXCPU="64"; fi

echo " "
echo -n "Enter the minimum amount of memory, in MB, that should be assigned to virtual machines in this SIG image definition (ex: 2048) >"
read MINMEM
if [ -z "$MINMEM" ]; then MINMEM="2048"; fi

echo " "
echo -n "Enter the maximum amount of memory, in MB, that should be assigned to virtual machines in this SIG image definition (ex: 65536) >"
read MAXMEM
if [ -z "$MAXMEM" ]; then MAXMEM="65536"; fi

echo " "
echo "Enter the list of target regions that this image should be visible to followed by the number of image replicas that should be available in each region."
echo "Replicas help in multi-VM deployment scenarios as the VM deployments can be spread to different replicas reducing the chance of instance creation processing"
echo "being throttled due to overloading of a single replica."
echo " "
echo "Multiple data centers can be selected as target regions and it is not necessary to specify the Azure Data Center which you have chosen your SIG to be deployed in."
echo " "
echo "Targets should be specified in the format 'dcname=replica_count'.  For example, canadacentral=2  would specify that the Canada Central Azure Data Center should"
echo "be a SIG target region and it should have two image replicas.  Failure to specify a replica will result in only a single image being available."
echo " "
echo "The input:         canadaeast=3 uksouth westcentralus=2 brazilsouth=2 eastasia"
echo "Would create target SIG regions in 'Canada East', 'UK South', 'West Central US', 'Brazil South', and 'East Asia' with the number of replicas being 3, 1, 2, 2, 1 respectively."
echo " "
echo "Valid Azure Regions are:"
echo "australiacentral"
echo "australiacentral2"
echo "australiaeast"
echo "australiasoutheast"
echo "brazilsouth"
echo "canadacentral"
echo "canadaeast"
echo "centralindia"
echo "centralus"
echo "eastasia"
echo "eastus"
echo "eastus2"
echo "francecentral"
echo "francesouth"
echo "japaneast"
echo "japanwest"
echo "koreacentral"
echo "koreasouth"
echo "northcentralus"
echo "northeurope"
echo "southcentralus"
echo "southeastasia"
echo "southindia"
echo "uksouth"
echo "ukwest"
echo "westcentralus"
echo "westeurope"
echo "westindia"
echo "westus"
echo "westus2"
echo " "
echo -n "Enter the target region list with replicas (if required) for all of the Azure Data Centers you would like the SIG to be visible to using the format above  >"
read TARGETLIST
if [ -z "$TARGETLIST" ]; then echo "You must select a target"; exit; fi

########## Test VM Creation to verify target availability

echo " "
echo -n "Enter the VM size which should be created for the test virtual machines (ex: Standard_D2_V2) >"
read VMSIZE
if [ -z "$VMSIZE" ]; then VMSIZE="Standard D2_V2"; fi

echo " "
echo -n "Enter the name of the VM which will be created in the SIG SOURCE REGION resource group (ex: myFirstVM) >"
read VMNAME
if [ -z "$VMNAME" ]; then VMNAME="myFirstVM"; fi

echo " "
echo -n "Enter one of the other target Azure Data Center(s) where this VM image will be accessible from (ex: southeastasia) >"
read AZUREDCIMAGEAVAILABLE
if [ -z "$AZUREDCIMAGEAVAILABLE" ]; then AZUREDCIMAGEAVAILABLE="southeastasia"; fi

echo " "
echo -n "Specify the name of a resource group to be created in the $AZUREDCIMAGEAVAILABLE region where the image will be available (ex: seasiarg)  >"
read SECONDRGNAME
if [ -z "$SECONDRGNAME" ]; then SECONDRGNAME="seasiarg"; fi

echo " "
echo -n "Enter the name of the VM which will be created in this resource group (ex: mySecondVM) >"
read SECONDVMNAME
if [ -z "$SECONDVMNAME" ]; then SECONDVMNAME="mySecondVM"; fi

echo " "
echo -n "Enter an Azure Data Center where this VM image will **NOT** be accessible from (ex: brazilsouth) >"
read AZUREDCIMAGEUNAVAILABLE
if [ -z "$AZUREDCIMAGEUNAVAILABLE" ]; then AZUREDCIMAGEUNAVAILABLE="brazilsouth"; fi

echo " "
echo -n "Specify the name of a resource group to be created in the $AZUREDCIMAGEUNAVAILABLE region where the image will **NOT** be available (ex: sbrazilrg)  >"
read THIRDRGNAME
if [ -z "$THIRDRGNAME" ]; then THIRDRGNAME="sbrazilrg"; fi

echo " "
echo -n "Enter the name of the VM which will be created in this resource group (ex: myThirdVM) >"
read THIRDVMNAME
if [ -z "$THIRDVMNAME" ]; then THIRDVMNAME="myThirdVM"; fi

echo " "
echo "==================================================================================================================================="
echo " "
echo "Suggested commands:"
echo " "

# Upload custom VHD to Azure

echo "#### Set "Default Output" to Table format"
echo "az configure"
echo " "

echo "#### Creates the resource group you will be working with"
echo "az group create -l $AZUREDC -n $RGNAME"
echo " "

echo "#### Creates a new storage account in the resource group"
echo "az storage account create -l $AZUREDC -n $STORAGEACCOUNTNAME -g $RGNAME --sku Standard_LRS"
echo " "

echo "#### Creates the blob container where you will be uploading your VHD image"
echo "az storage container create --account-name $STORAGEACCOUNTNAME --name $CONTAINERNAME"
echo " "

echo "#### Lists the security account keys required to create a storage container in the new account"
echo "az storage account keys list -g $RGNAME -n $STORAGEACCOUNTNAME"
echo " "

echo "#### Upload the disk image"
echo "az storage blob upload --account-name $STORAGEACCOUNTNAME --account-key <STORAGE-ACCOUNT-KEY-OBTAINED-FROM-PREVIOUS-COMMAND> --container-name $CONTAINERNAME --type page --file $FULLPATHTOFILE --name $NAMEOFVHD"
echo " "

echo "#### Obtain the URL assigned by Azure to the uploaded VHD disk"
echo "az storage blob url -c $CONTAINERNAME -n $NAMEOFVHD --account-name $STORAGEACCOUNTNAME"
echo " "

# Begin SIG deployment

echo "#### Register for SIG Feature since it is still in preview"
echo "az feature register --namespace Microsoft.Compute --name GalleryPreview"
echo " "

echo "#### Register the provider for the new feature"
echo "az provider register -n Microsoft.Compute"
echo " "

echo "#### Wait until the new feature changes from 'Registering' to 'Registered'"
echo "watch -n 1 'az feature list |grep -i GalleryPreview'"
echo " "

echo "#### Create the Shared Image Gallery"
echo "az sig create -g $RGNAME -l $AZUREDC -r $SIGIMAGEGALLERYNAME"
echo " "

echo "#### Create the Shared Image Gallery Definition"
echo "az sig image-definition create -g $RGNAME -r $SIGIMAGEGALLERYNAME -i $GALLERYIMAGEDEFINITION -p $IMAGEPUBLISHER -f $IMAGEOFFER -s $IMAGESKU --minimum-cpu-core $MINCPU --maximum-cpu-core $MAXCPU --minimum-memory $MINMEM --maximum-memory $MAXMEM --os-type Linux"
echo " "

echo "#### Create the VM image from source blob storage"
echo "az image create -n $NAMEOFIMAGETEMPLATE -g $RGNAME --os-type Linux --source https://$STORAGEACCOUNTNAME.blob.core.windows.net/$CONTAINERNAME/$NAMEOFVHD"
echo " "

echo "#### Determine the Resource ID of the VM Image Template just created"
echo "az image list -g $RGNAME --query '[].{objectID:id}' |grep $NAMEOFIMAGETEMPLATE"
echo " "

echo "#### Create the Shared Image Gallery Initial Version using the image at specified the Resource ID"
echo "az sig image-version create -g $RGNAME -r $SIGIMAGEGALLERYNAME -i $GALLERYIMAGEDEFINITION -e $GALLERYIMAGEVERSION -l $AZUREDC --target-regions $TARGETLIST --managed-image '/subscriptions/$AZURESUBSCRIPTIONID/resourceGroups/$RGNAME/providers/Microsoft.Compute/images/$NAMEOFIMAGETEMPLATE'"
echo " "

echo "#### Create a virtual machine based on this SIG image [Success]"
echo "az vm create -g $RGNAME -n $VMNAME --accelerated-networking true --size $VMSIZE --image '/subscriptions/$AZURESUBSCRIPTIONID/resourceGroups/$RGNAME/providers/Microsoft.Compute/galleries/$SIGIMAGEGALLERYNAME/images/$GALLERYIMAGEDEFINITION/versions/$GALLERYIMAGEVERSION'"
echo " "

echo "#### Create a new resource group in an additional region which you have made this image available in"
echo "az group create -n $SECONDRGNAME -l $AZUREDCIMAGEAVAILABLE"
echo " "

echo "#### Create a virtual machine based on this SIG image [Success]"
echo "az vm create -g $SECONDRGNAME -n $SECONDVMNAME --accelerated-networking true --size $VMSIZE --image '/subscriptions/$AZURESUBSCRIPTIONID/resourceGroups/$RGNAME/providers/Microsoft.Compute/galleries/$SIGIMAGEGALLERYNAME/images/$GALLERYIMAGEDEFINITION/versions/$GALLERYIMAGEVERSION'"
echo " "

echo "#### Create a new resource group in an additional region which you have *NOT* made this image available in"
echo "az group create -n $THIRDRGNAME -l $AZUREDCIMAGEUNAVAILABLE"
echo " "

echo "#### Create a virtual machine based on this SIG image [Failure]"
echo "az vm create -g $THIRDRGNAME -n $THIRDVMNAME --accelerated-networking true --size $VMSIZE --image '/subscriptions/$AZURESUBSCRIPTIONID/resourceGroups/$RGNAME/providers/Microsoft.Compute/galleries/$SIGIMAGEGALLERYNAME/images/$GALLERYIMAGEDEFINITION/versions/$GALLERYIMAGEVERSION'"
echo " "
echo "=========================================================================================================================================================="
echo " "
echo "You should recieve a similar failure error message to this one if you try to create the third VM in the Azure Data Center where the SIG is not targeted:"
echo " "

echo "Deployment failed. Correlation ID: a3d76719-0a5a-4d13-8b22-691ee5476717. {"
echo "  "error": {"
echo "    "code": "ImageNotFound","
echo "    "message": "The platform image '/subscriptions/$SUBSCRIPTIONID/resourceGroups/$RGNAME/providers/Microsoft.Compute/galleries/$SIGIMAGEGALLERYNAME/images/$GALLERYIMAGEDEFINITION/versions/$GALLERYIMAGEVERSION' is not available. Verify that all fields in the storage profile are correct.","
echo "    "target": "imageReference""
echo "  }"
echo "}"

