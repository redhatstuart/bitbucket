#!/bin/bash

# Written by Stuart Kirk
# stuart.kirk@microsoft.com
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# This script downloads an Azure Marketplace disk image and saves it as a managed disk to the 
# specified resource group.

# Obtain our current auth token & subscription ID
export TOKEN="`az account get-access-token --query 'accessToken' -o tsv`"
export SUBID="`az account list -o tsv |grep -i true |awk '{print $2}'`"

# Obtain image data
echo -n "Provide the Azure data center location you are working with (ex: eastus2) >>> "
read AZUREDC

echo " "
echo -n "Provide the resource group name to deposit the managed disk image (ex: myimagerg) >>> "
read RG_NAME

echo " "
echo -n "Provide the name of the managed disk to be created (ex: myimage) >>> "
read DISKNAME

echo " "
echo -n "Provide the Azure disk image Publisher (ex: OpenLogic) >>> "
read PUBLISHER

echo " "
echo -n "Provide the Azure disk image offer (ex: CentOS) >>> "
read OFFER

echo " "
echo -n "Provide the Azure disk image SKU (ex: 7.5) >>> "
read SKU

echo " "
echo -n "Provide the Azure disk image version (ex: 7.5.201808150) >>> "
read VERSION

# Hard-set variables
export AZUREDC=$AZUREDC
export RG_NAME=$RG_NAME
export DISKNAME=$DISKNAME
export PUBLISHER=$PUBLISHER
export OFFER=$OFFER
export SKU=$SKU
export VERSION=$VERSION

echo " "
echo "Attempting to get $PUBLISHER:$OFFER:$SKU:$VERSION"

sleep 5

# Create RG and make API call
az group create --name $RG_NAME --location $AZUREDC
cat get-marketplace-image.json | envsubst | curl -v -X PUT -H 'Content-Type: application/json; charset=utf-8' -H 'Authorization: Bearer '$TOKEN'' -d @- https://management.azure.com/subscriptions/$SUBID/resourceGroups/$RG_NAME/providers/Microsoft.Compute/disks/$DISKNAME?api-version=2019-07-01

# Output
echo " "
echo " "
echo "To create the disk image, execute 'az image create -n $DISKNAME-image -g $RG_NAME --source $DISKNAME --os-type X' where 'X' is either 'Windows' or 'Linux' depending on the type of image."

exit 0
