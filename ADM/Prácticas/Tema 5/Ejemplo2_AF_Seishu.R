###########################################
#ANALISIS DE DATOS MULTIVARIANTES.        #  
#GRADO EN MATEM�TICAS.                    #
#DOBLE GRADO EN MATEM�TICAS Y ESTAD�STICA #
#AN�LISIS FACTORIAL: EJEMPLO SEISHU       #
###########################################
#El fichero "Seishu.txt" contiene el valor de 
#10 caracter�sticas para 30 marcas de vino Seishu
#La variable Sake es el llamado 
#"Sake Meter Value", cuanto m�s alto positivo,
#m�s seco, cuanto m�s negativo, m�s dulce

#1. Leer los datos y calcular las medidas
#   de adecuaci�n muestral. Aplicar el test 
#   de esfericidad de Bartlett
#2. Estimar el modelo AF mediante el m�todo 
#   de Componentes Principales (variables tipificadas)  
#3. Estimar el modelo AF mediante el m�todo 
#   de Factores Principales (variables tipificadas) 
#   usando el paquete psych
#4. Estimar el modelo AF mediante el m�todo 
#   de m�xima verosimilitud (variables tipificadas) 
#   (funci�n factanal)

#1. Leer los datos y calcular las medidas
#de adecuaci�n muestral. Aplicar el test
#de esfericidad de Bartlett
#########################################
datos= read.table("Seishu.txt",header=FALSE)
colnames(datos)= c("Sabor","Olor","Ph",
                    "Acidez1","Acidez2","Sake",
                    "Az�car_reducido","Az�car_Total",
                    "Alcohol", "Formyl-Nitrog.")
datos
summary(datos)

#Medidas de adecuaci�n muestral
#install.packages("rela")
library(rela)
PAF=paf(as.matrix(datos))
#KMO mide la proporci�n de varianza que es com�n, 
#atribuible a factores subyacentes
PAF$KMO #Aqu� un 55% (Bajo)
PAF$MSA  #Medidas de adecuaci�n muestral

#el test de esfericidad de Bartlett contrasta 
#la hip�tesis nula de que la matriz
#var-cov es proporcional a la identidad, 
#en este caso, R=I, implicar�a la
#incorrelaci�n entre las variables
PAF$Bartlett #estad�stico del test
#c�lculo del p-valor
p=ncol(datos)
gl= p*(p-1)/2
1-pchisq(PAF$Bartlett,gl)   # Contraste significativo  
## Por tanto, no aceptmos la esfericidad y aplicamos AF.

#(normalidad multivariante cuestionable
#p.value.small
#[1] 2.904e-05 )


#2. AF mediante el m�todo de 
#   Componentes Principales (R)  
############################
R=cor(datos)
(autoval= eigen(R)$values)       
(autovec= eigen(R)$vectors)
plot(princomp(R))  #Parece sugerir 4
100*sum(autoval[1:4])/10   #84.4%

m= 4  #n�mero de factores
L=autovec[,1:m]%*%diag(sqrt(autoval[1:m]))  #Cargas factoriales
rownames(L)= colnames(datos)     #Coinciden con las correlaciones
colnames(L)= paste("Factor",1:m)  #entre variables y factores (R)
round(L,3)
(h= apply(L^2,1,sum))   #comunalidades
(psi= diag(R)-h)        #varianzas espec�ficas
cbind(L,h,psi)           

#Contribuciones de los factores
contrib=   apply(L^2,2,sum)
contrib   #conciden con autoval[1:m]
resumen= matrix(NA,nrow=m,ncol=3)
resumen[,1]=  contrib[1:m]
resumen[,2]= 100*resumen[,1]/sum(autoval)
resumen[,3]= cumsum(resumen[,2])
colnames(resumen)= c("Varianza","Porcentaje",
                     "Porcentaje acumulado")
resumen

#El siguiente gr�fico representa las variables 
#seg�n las cargas factoriales
plot(L,type="n",main="Cargas factoriales",
 xlab="Factor 1",ylab="Factor 2")
text(L,labels=rownames(L),cex=0.8)
grid()
abline(h=0,v=0,lty=2)

#Rotaci�n varimax, simplifica la interpretaci�n
(rotvarimax= varimax(L))
(Lrot= varimax(L)$loadings)
plot(Lrot[,1:2],type="n",
     main="Cargas factoriales, rotaci�n varimax",
     xlab="Factor 1",ylab="Factor 2")
text(Lrot[,1:2],labels=rownames(L),cex=0.8)
grid()
abline(h=0,v=0,lty=2)
(hrot= apply(Lrot^2,1,sum))  #comunalidades
(psirot= diag(R)-hrot)        #varianzas espec�ficas
cbind(L,h,psi,Lrot,hrot,psirot)

#Puntuaciones factoriales para la rotaci�n varima
#Para la soluci�n de componentes principales         
#se puede usar m�nimos cuadrados ordinarios
#Los datos deben ser centrados, 
#o sea, scale(...center=TRUE)
#Como estamos trabajando con la matriz de 
#correlaciones, en realidad las variables 
#han de ser tipificadas, por
#tanto tambi�n scale=TRUE
Xcent=scale(datos,center=TRUE,scale=TRUE)
Frot=t(solve(t(Lrot)%*%Lrot)%*%t(Lrot)%*%t(Xcent))
rownames(Frot)= 1:nrow(datos)
Frot

#Nube de puntos de las puntuaciones factoriales
plot(Frot,type="n",main="Puntuaciones factoriales 
     mediante m�nimos cuadrados \n Rotaci�n varimax")
text(Frot,labels=rownames(Frot),cex=0.7,col="red")
abline(h=0,v=0,lty=2,col="blue")

plot(Frot[,c(1,3)],type="n",
     main="Puntuaciones factoriales mediante m�nimos cuadrados \nRotaci�n varimax")
text(Frot[,c(1,3)],labels=rownames(Frot),cex=0.7,col="red")
abline(h=0,v=0,lty=2,col="blue")

#En general, los pares (Fi,Fj), con i<j

#Aproximaci�n a R
R4=Lrot%*%t(Lrot) + diag(psirot)
R4
R
Rresid= R-R4
sum(Rresid^2)
sum(autoval[-c(1:m)]^2)


#3. M�todo de Factores  Principales    
#####################################
#install.packages(c("psych","GPArotation"))
library(psych)    #Necesita la librer�a GPArotation
library(GPArotation)
af.fp = fa(datos,4,fm="pa",rotate="varimax",max.iter=350) ##
af.fp 

#####################################
#4. Estimar el modelo AF mediante el m�todo 
#   de m�xima verosimilitud (variables tipificadas) 
#   (funci�n factanal)
###################################################
af.mv = factanal(datos,m,scores="Bartlett")
#scores="regresssion" para el otro m�todo         
af.mv #Ya aplica rotaci�n varimax; contraste satisfactorio
cbind(Comunalidad=1-af.mv$uniqueness,Especificidad=af.mv$uniqueness)
L=loadings(af.mv); L
for (i in 1:(m-1))
 for (j in (i+1):m)
  { plot(L[,c(i,j)],type="n",
         main="Cargas factoriales; M�xima Verosimilitud\nRotaci�n varimax")
      text(L[,c(i,j)],labels=rownames(L),cex=0.7,col="red")
    abline(h=0,v=0,lty=2,col="blue")
  }
#Puntuaciones factoriales; 
F= af.mv$scores
rownames(F)= 1:nrow(datos)
for (i in 1:(m-1))
 for (j in (i+1):m)
  { plot(F[,c(i,j)],type="n",
         main="Puntuaciones factoriales Barlett \nRotaci�n varimax")
      text(F[,c(i,j)],labels=rownames(F),cex=0.7,col="red")
    abline(h=0,v=0,lty=2,col="blue")
  }

