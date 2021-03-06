################################
#    Scripts �tiles para R     #
################################
#                              #
################################

################################
#         Introducci�n         #
################################

# Leer datos de entrada
datos<- read.table("datos.extension",header=TRUE,row.names=1)
str(datos)      # ESTRUCTURA DEL OBJETO
datos$v1        # ACCEDER A UNA VARIABLE
dim(datos)      # NUMERO DE FILAS Y COLUMNAS
summary(datos)  # RESUMEN NUMERICO
attach(datos)   # PARA USAR DIRECTAMENTE EL NOMBRE DE LAS VARIABLES

# Plot simple de 2 variables
# Si DATOS tiene m�s, coge las dos primeras

plot(v1,v2,main="T�tulo del gr�fico", xlim=c(110,180)) #PUNTOS
text(v1,v2,label=rownames(datos),adj=1,col="red")
grid()          # REJILLA

# Recta de regresi�n 
regre<-lm(Peso~Altura)          # V.DEPEND.~V.INDEPEND.
abline(regre,lwd=2,col="blue")  # Plotea una recta en la gr�fica anterior

# La funci�n pairs da los plots de las correlaciones

# Boxplot
boxplot(v1)  # Cl�sico diagrama de bigotes y cajas
## Representa bloxplots de v1 spliteados seg�n v2
boxplot(v1~v2,main="T�tulo",xlab="v2",names=c("vector nombres variable x")) 

# Apply es ideal para trabajar con matrices
apply(decath,1,var)
apply(decath,2,sd)

# Dibujar Medias 
matplot(matriz,type="l",xlab="Eje x",ylab="Eje Y",lwd=2,
        lty=1:ng, main="T�tulo",col=1:ng)
## Con el comando lines podemos dibujar sobre la gr�fica anterior la l�nea de las medias.

##############################
##############################
#         Contraste          #
#           Normal           #
#        Univariante         #
##############################
##############################

# La funci�n ananor(x) [hay que importarla] mide la normalidad univariante
# de una muestra de aleatoria, al igual que el Test de Shapiro

# La funci�n t.test(x,mu=a) testea la hip�tesis H0: E[X]=a. Dejamos los comandos
# para ilustrar lo observado
resul<-  t.test(x,mu=a);

## Dentro de resul tenemos opciones como $parameter, etc.

# Si tenemos dos poblaciones y queremos testear H0:E[x]=E[y], testeamos la
# igualdad de varianzas primero con
var.test(x,y) 

# Luego volvemos a realziar el contraste. Con "alt" podemos dar el caracter
# de la hip�tesis alternativa. Si H1:E[x]<E[y] entonces
t.test(x,y,alt="less",var.equal=TRUE) # Por defecto False


##############################
##############################
#         Contraste          #
#           Normal           #
#        Multivariante       #
##############################
##############################

# Estudio de la normalidad multivariante. 

# Muchas veces necesitaremos un FACTOR que identifique los grupos dentro
# de un conjunto de datos. Tenemos dos opciones, tomarlos separados de los datos
g = factor("Aqu� tienes que meter un vector")

## O bien hacer que una columna sea un factor
datos$v3<- factor(datos$v3)
levels(datos$v3)<- c("Si quieres puedes ponerle nombres en vez de numeros")

## Un ejemplo del uso de un factor es un plot o pairs por grupos:
g = factor("Aqu� tienes que meter un vector")
plot(Z,col=c("red","blue")[g])
pairs(Z,col=c("red","blue")[g])

## Tambi�n podemos aplicar funciones por grupo
by(Z, g,funcion)
by(Z,g,function(M)  apply(M,2,mean));

# Para testear la normalidad multivariante utilizamos el Test de Mardia.
source("Test_Mardia.R")
mardiaTest(datos)
by(datos,g,mardiaTest)

##############################
#        Contrastes          #
############################## 

# Contraste de una poblaci�n para H0:E[x]=vector. Para este y el resto de test debemos
# asumir igualda de matrices de varianzas covarianzas.
HotellingsT2(datos,mu = c(0,0,0))   

# Contraste de dos poblaciones para H0:E[x]-E[y]=vector 

## Si tenemos dos matrices de datos (no necesariamente independientes) [PREGUNTAR]
HotellingsT2(X,Y, mu = rep(-0.5,4))

## Si lo tenemos separados con un factor podemos meter directamente la f�rmula
## Preguntar
HotellingsT2(Z ~ g, mu = rep(-0.5,4))

# Paralelimos
A<- matrix(0,p-1,p)
for (i in 1:(p-1))
  A[i,c(i,i+1)]<-c(-1,1)
Xtrans<-  t(A%*%t(as.matrix(dato)))
by(Xtrans,datos$Grupo,mardiaTest)  
HotellingsT2(Xtrans ~ g)

# Perfil medio
B<- matrix(1,nrow=1,ncol=p)
XtransB<-  t(B%*%t(as.matrix(datos)))
var.test(XtransB~g)                 # Supongamos que se rechaza
t.test(XtransB ~ g,var.equal=FALSE) 


##############################
#          An�lisis          #
#             de             #
#       Conglomerados        #
##############################

### Funci�n Daisy ###

# Es una funci�n an�loga a dist para situacioens donde tenemos variables de distinto tipo.

D <- daisy(flower,type = list(asymm = c("V1", "V3"), symm= 2,ordratio= 7,logratio= 8))

## Como hay un factor se coge la distancia de bower automaticamente

####################################
## M�todo jer�rquico aglomerativo ##
####################################

### M�todo Hclust ### 

# Puedes usar otros m�todos como "single" o "average". 
D<- dist(datos)
round(D,1)
conglo<- hclust(D,method="complete") ## Solo acepta la matriz de disimilaridad
plot(conglo, cex=0.8,labels=rownames(datos),
     main="Dendrograma",xlab="Completo",
     sub="Distancias",ylab="Distancias",col="blue")

#Lista de uniones que se van produciendo. Se una el de la primera columna con el del
#segundo y la distancia en la tercera. -n representa el caso n, en positivo representa
#un conglomerado. Por ejemplo, -1 1 indica que el 1 se une al conglomerado 1, donde 
#(en este caso) est�n el 2 y el 9.
cbind(conglo$merge,conglo$height) 

# Si queremos solo una cantidad espec�fica de clusters (ej k=3), computamos
cluster <- cutree(conglo, k = 3)
table(cluster)
split(mamiferos,cluster)
## Lo mismo con otro formato
by(mamiferos,cluster,function(x) x) 

## Comparar cutrees con table(tabla1,tabla2)

# Calcular los centroides:
Centros=by(mamiferos,cluster,colMeans)                # Formato list
Centros=t(sapply(split(mamiferos,cluster),colMeans))  # Formato matrix

# Estad�stico F de ANOVA. As� vemos las variables con mayor variabilidad.
apply(mamiferos,2, function(x) 
  summary(lm(x~factor(cluster)))$fstatistic[1])


### M�todo Agnes ### 

# Agnes es una alternativa a hclust. Acepta tanto matriz de disimilaridad (objeto dist)
# como matriz de datos, en cuyo caso hay que especificar una m�trica.
agnclus <- agnes(mamiferos, metric = "euclidean", # Ejemplos de agnes con datos
                 stand = FALSE,method="complete") # y m�todo complete

# Los objetos agnes tienen $ac, el coeficiente de aglomeraci�n.


####################################
##      M�todo de partici�n       ##
####################################

### M�todo k-medias ###

# Tenemos que partir de k centros iniciales. Por ejemplo, podemos partir de los 
# que nos da un an�lisis jer�rquico. La entrada debe ser la matriz de datos.
data(swiss)
h<- hclust(dist(swiss),method="complete")
cluster<- cutree(h,3)
Centros= t(sapply(split(swiss,cluster),colMeans))  #Formato matrix
km<- kmeans(swiss,Centros)   
km

# Sin embargo tambi�n podemos utilizar kmeans dando los centros que queremos y con 
# un cierto numero de soluciones iniciales. En el ejemplo ponemos 15
km3 <- kmeans(swiss, 3, nstart = 15)

# Calcular Error Cuadratico Medio
ECM<- mean((datos-km$centers[km$cluster,])^2)


### M�todo de K-medioides ### 

#Funcion pam.`Al igual que kmeans acepta tanto datamatrix como matriz de disimilaridad.` 
agric.pam<- pam(agriculture,2) 
## El plot nos da dos gr�ficas por las que habr�a que preguntar la verdad. 
plot(agric.pam)
## Recuerda que en help puedes ver qUe $id.med son los �ndices de los medioides en la matriz
## mientras que $mediodes son las posiciones de los mediodes.

# Lo buena o mala que es una soluci�n podemos verlo con agric.pam.i$silinfo$avg.width.
# Cuanto m�s cercano a 1  mejor es la soluci�n. Menos de 0.50 mal asuntillo.
# Por ejemplo, usando tenemos una gr�fica muy bonita de la calidad en funci�n del numero
# de medioides

### M�todo clara ###

# Es mejor para conjunto de datos de gran tama�o que pam. Simplemente usar el m�todo "clara"


####################################
##  Mixturas de Normales Multiv.  ##
####################################

# Utilizamos Mclust que est� en la liberaria mclust. Simplemente 
Mclusfaith<-Mclust(data)

# Como salida tenemos $z, para cada caso, prob. de pertenencia a cada grupo.
matz<-Mclusfaith$z
round(matz[1:10,],4) 

#### Preguntar todo lo siguiente de los 2 ultimso ejercicios
