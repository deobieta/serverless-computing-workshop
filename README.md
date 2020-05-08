# Serverless Computing con Terraform en AWS

# UN CAMBIO AQUI

**Saltar a tema:**

* [Resumen del taller](https://github.com/deobieta/serverless-computing-workshop/blob/master/README.md#resumen-del-taller)
* [Crear usuario administrador para el taller](https://github.com/deobieta/serverless-computing-workshop/blob/master/README.md#crear-usuario-administrador-para-el-taller)
* [Establece llaves de acceso en la configuracion de Terraform](https://github.com/deobieta/serverless-computing-workshop/blob/master/README.md#establece-llaves-de-acceso-en-la-configuracion-de-terraform)
* [Ejercicio 1. Lambda](https://github.com/deobieta/serverless-computing-workshop/blob/master/README.md#lambda)
* [Ejercicio 2. Blue Green deployment](https://github.com/deobieta/serverless-computing-workshop/blob/master/README.md#blue-green)
* [Ejercicio 3. Canary release](https://github.com/deobieta/serverless-computing-workshop/blob/master/README.md#canary)
* [Ejercicio 4. Lambda blackbox](https://github.com/deobieta/serverless-computing-workshop/blob/master/README.md#blackbox)
* [Ejercicio 5. Lambda layers](https://github.com/deobieta/serverless-computing-workshop/blob/master/README.md#layers)
* [Limpiar taller](https://github.com/deobieta/serverless-computing-workshop/blob/master/README.md#limpiar-taller)


## Resumen del taller

El taller tiene como finalidad hacer una introducción al uso de herramientas de automatización de infraestructura en [AWS Lambda](https://aws.amazon.com/lambda/). 

Antes de comenzar el taller es necesario completar los siguientes pasos:

* [Tener una cuenta en AWS](<https://aws.amazon.com>)
* [Instalar Terraform](<https://www.terraform.io/downloads.html>)
* [Instalar awscli](<https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html>)

Las herramientas que utilizaremos en el taller son:

* [Terraform](<https://www.terraform.io/>) (Herramienta para construir, cambiar y versionar infraestructura de manera segura y eficiente.)
* [awscli](<https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html>) (Cliente para interactuar con las APIs de los servicios de AWS)

## Crear usuario administrador para el taller

Entra a la cuenta que vas a utilizar en el taller y navega a la consola de usuarios [IAM](https://console.aws.amazon.com/iam/home?region=us-east-2#/users).

Agrega un nuevo usuario que se llame "workshop"

![user output](/readme-images/iam/1.png)

Dar permisos de administrador al nuevo usuario (AdministratorAccess).

IMPORTANTE: Por practicidad le damos estos permisos al usuario, en el mundo real siempre es mejor dar el menor número de permisos a un usuario o rol.

![perms output](/readme-images/iam/2.png)

Descargar las llaves de acceso para hacer llamadas al API de AWS.

![keys output](/readme-images/iam/3.png)

## Establece llaves de acceso en la configuracion de Terraform

Para establecer las llaves de acceso puedes exportar las credenciales como variables de ambiente. 

    $ export AWS_ACCESS_KEY_ID="AKIAJ3RAVUDDQWJADQSQ"
    $ export AWS_SECRET_ACCESS_KEY="BpXA8AbiC1vgZUTVrKzsxB/zRnPCaIe8YjP0Q9VDu"

También puedes usar el editor de tu elección, abrir el archivo 1-workshop-mgmt/terraform/provider.tf, descomentar las dos lineas de las llaves de accesso y reemplazar el texto "ACCESS_KEY_HERE" y "SECRET_KEY_HERE".


## Configura awscli con las llaves de acceso

    $ aws configure
    AWS Access Key ID [None]: AKIAJ3RAVUDDQWJADQSQ
    AWS Secret Access Key [None]: BpXA8AbiC1vgZUTVrKzsxB/zRnPCaIe8YjP0Q9VDu
    Default region name [us-west-2]: us-east-2


## Lambda

    $ cd 1-workshop-lambda/
    $ terraform init
    $ terraform plan
    $ terraform apply
    
    Do you want to perform these actions?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.

    Enter a value: yes

Terraform creará un plan de ejecución y al final pregunta si quieres aplicar el plan, escribe "yes" para aplicar los cambios.
Al aplicar el plan, Terraform dará un valor de salida que nos indica el número de versión de nuestra función.
Podemos invocar la función de la siguiente forma:

    $ aws lambda invoke --region=us-east-2 --function-name=simple output.txt

Toma nota del valor de salida "workshop_bucket_name" ya que lo usaremos en los próximos ejercicios.

## Blue-Green 

Los despliegues "Blue-Green" son una técnica que reduce el tiempo de falla de una 
aplicación, consiste en correr dos ambiente idénticos al mismo tiempo pero solo un ambiente se encargará de servir el 100% del tráfico. Si el nuevo ambiente funciona correctamente podemos apagar el ambiente anterior, de lo contrario podemos regresar 
a una versión estable al ambiente anterior.  

NOTA: para este ejercicio se requiere un bucket de S3 puedes saber el nombre del bucket de los valores de salida del ejercicio anterior. El nombre debe ser algo parecido a "serverless-computing-workshop-XXXXXXXXX"

terraform apply -var="app_version=1"

    $ cd 2-workshop-lambda-blue-green/function
    $ zip simple.zip main.py
    $ aws s3 cp simple.zip s3://serverless-computing-workshop-XXXXXXXXX/v1/simple.zip
    $ cd ..
    $ terraform init
    $ terraform plan -var="app_version=1"
    $ terraform apply -var="app_version=1"

En este ejercicio la función lambda la podemos invocar desde un recurso de API gateway. Terraform dará un valor de salida (endpoint) que indica la URL donde podemos probar nuestra función con el comando curl o desde un navegador.
    
Crea otra versión de lambda editando el script main.py.

    $ cd function/
    $ nano main.py
    $ zip simple.zip main.py
    $ aws s3 cp simple.zip s3://serverless-computing-workshop-XXXXXXXXX/v2/simple.zip
    $ cd ..
    $ terraform apply -var="app_version=2"

El mismo endpoint debe ahora servir la función actualizada. Supongamos que algo malo pasó con nuestra 
función actualizada, lo único que debemos hacer para arreglarlo es correr "terraform apply"  con la versión
anterior.

    $ terraform apply -var="app_version=1"

Y volvemos a una versión estable.

## Canary

Un "Canary release" es una técnica usada para reducir el riesgo al introducir cambios de nuevas versiones
de software de tal forma que no impacten de gran manera o total los sistemas que estamos actualizando. Esto se logra introduciendo los cambios de forma gradual en pequeños porcentajes al tráfico que sirve la aplicación hasta lograr que el 100% del tráfico se sirva con el sistema actualizado.


    $ cd 3-workshop-lambda-canary/
    $ terraform init
    $ terraform plan
    $ terraform apply

Terraform dará un valor de salida (endpoint) que indica la URL donde podemos probar nuestra función con el comando curl o desde un navegador.

Actualmente nuestro stack se ve algo así:

    apigateway -> alias -> lambda

Debemos crear otra versión de la función para lograrlo edita el archivo "function/main.py" y repite el comando "terraform apply" esta vez terraform 
publicará otra versión de la función en  vez de reemplazarla, esto se logra con la directiva "publish = true" dentro del recurso aws_lambda_function en el 
archivo lambda.tf.

    $ nano function/main.py
    

IMPORTANTE: Antes de aplicar los cambios en Terraform debemos configurar el ruteo entre las dos versiones de nuestra función para lograrlo debemos editar el archivo lambda-alias.tf y descomentar routing_config. 

    $ terraform apply

Ahora nuestro stack se ve así:

                      |-> lambda versión 1 (50%)
    apigateway -> alias
                      |-> lambda versión 2 (50%)


## Black box o módulo de Terraform

Los módulos de terraform nos ayudan a tener menos código, dejar de repetir recursos y copiar archivos. También es una buena forma de crear cajas negras 
(black box) en donde podemos definir cómo es que nuestra infraestructura se va a crear y decidir qué recursos y atributos vamos a exponer a colaboradores que no necesariamente deben tener total acceso a la infraestructura. 

    $ cd 4-workshop-lambda-blackbox/
    $ terraform init
    $ terraform plan
    $ terraform apply

    Do you want to perform these actions?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.

    Enter a value: yes
    
El archivo blackbox.tf contiene 10 lineas de código y creo exactamente la misma infraestructura que nuestros ejercicios anteriores. La diferencia es que 
la mayor cantidad de código se encuentra en el directorio de módulos. En este ejemplo incluimos módulos de directorios locales dentro del mismo 
repositorio de git pero también se pueden obtener de forma remota especificando la dirección del repositorio en "source".

## Layers

Lambda tiene una funcionalidad de capas que puede ayudar a acelerar el tiempo de construcción y despliegue de funciones. Cada función puede tener hasta 5 capas de código que se puede compartir entre otras funciones. De esta forma se pueden hacer capas de librerías que se usan en una o varias funciones, librerías que pueden llegar a ser bastantes y que tardan en ser empacadas cada vez que hay un despliegue de funciones. En el ejercicio que vamos a realizar terraform va a crear una capa (layer) de lambda con el contenido del directorio python-layer, dentro hay una estructura de directorios que es necesaria para que nuestra función final pueda hacer uso del código de la capa. El código de las capas se instalan dentro del directorio /opt así es que nuestra capa quedará al final de la siguiente forma: /opt/python/lib/python3.7/site-packages/from_layer.py.  Esto quiere decir que el código va a estar disponible al momento de ejecutar nuestra función de lambda normal.

    $ cd 5-workshop-lambda-layers/
    $ terraform init
    $ terraform plan
    $ terraform apply

    Do you want to perform these actions?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.

    Enter a value: yes


Entra a la consola de lambda en tu navegador, la región que usamos en us-east-2 (Ohio). 
Da clic en la función "python-lambda-with-layer". En la sección de "Designer" podemos ver que nuestra función está usando una capa, si damos clic en la capa la consola nos dirá el nombre y versión. En la sección de "Function code" podemos ver que nuestra función está incluyendo una librería que se llama "from_layer" y en la línea 4 hacemos uso de la librería para regresar un nombre "name = fl.get_name()".

Prueba la función lambda dando clic en el botón de "Test", la prueba requiere de un evento en el nombre del evento puedes poner el nombre que desees, da clic en "Test" de nuevo.  Ve los detalles de la ejecución.

Cambia el nombre que la función from_layer regresa en el archivo python-layer/python/lib/python3.7/site-packages/from_layer.py

    $ terraform apply

Prueba la función de nuevo desde la consola ahora debe mostrar el nombre que editaste.

## Limpiar taller

    $ cd 5-workshop-lambda-layers/
    $ terraform destroy

    $ cd 4-workshop-lambda-blackbox/
    $ terraform destroy

    $ cd 3-workshop-lambda-canary/
    $ terraform destroy

    $ cd 2-workshop-lambda-blue-green/
    $ terraform destroy

Antes de borrar el bucket de S3 debe estar vació, eso lo puedes lograr desde la consola de S3.

    $ cd 1-workshop-lambda/
    $ terraform destroy

![user output](/readme-images/mgc.gif)
