# -------------------------------
.macro read_int # Solicitar un entero al usuario
	li $v0,5 # Syscall para leer un entero
	syscall
.end_macro

.macro print_label (%label) # Imprimir una etiqueta
	la $a0, %label # Carga la direccion de la etiqueta
	li $v0, 4 # Syscall para imprimir una cadena
	syscall
.end_macro

.macro done # Terminar el programa
	li $v0,10 # syscall para salir
	syscall
.end_macro	

.macro print_error (%errno) # Imprimir un mensaje de error
	print_label(error) # Imprime el mensaje de error inicial
	li $a0, %errno # Carga el numero de error a imprimir
	li $v0, 1 # Syscall para imprimir un entero
	syscall
	print_label(return) # Imprime un salto de linea
.end_macro
# -------------------------------

# -------------------------------
.data
slist:	.word 0
cclist: .word 0
wclist: .word 0
schedv: .space 32
menu:	.ascii "Colecciones de objetos categorizados\n"
		.ascii "====================================\n"
		.ascii "1-Nueva categoria\n"
		.ascii "2-Siguiente categoria\n"
		.ascii "3-Categoria anterior\n"
		.ascii "4-Listar categorias\n"
		.ascii "5-Borrar categoria actual\n"
		.ascii "6-Anexar objeto a la categoria actual\n"
		.ascii "7-Listar objetos de la categoria\n"
		.ascii "8-Borrar objeto de la categoria\n"
		.ascii "0-Salir\n"
		.asciiz "Ingrese la opcion deseada: "
error:	.asciiz "Error: "
return:	.asciiz "\n"
catName:.asciiz "\nIngrese el nombre de una categoria: "
selCat:	.asciiz "\nSe ha seleccionado la categoria: "
idObj:	.asciiz "\nIngrese el ID del objeto a eliminar: "
objName:.asciiz "\nIngrese el nombre de un objeto: "
success:.asciiz "La operación se realizo con exito\n\n"
indicador: .asciiz " > "
separador: .asciiz " - "
objNotFound: .asciiz "Not Found: Objeto no encontrado en la lista\n"
label201:	.asciiz "No hay categorias\n"
label202:	.asciiz "Existe una sola categoria\n"
label301:	.asciiz "No hay categorias para listar\n"
label401:	.asciiz "No hay categorias para eliminar\n"
label501:	.asciiz "No hay categoria para almacenar el objeto\n"
label601:	.asciiz "No hay categoria creada\n"
label602:	.asciiz "No hay objetos de la categoria para listar\n"
label701:	.asciiz "No existe categoria para eliminar objeto\n"
# -------------------------------

# -------------------------------
.text
main:

	# -------------------------------
	# Inicializacion del vector scheduler (schedv)
	# Este vector almacena las direcciones de las funciones asociadas al menu
	la $t0, schedv
	la $t1, newcategory
	sw $t1, 0($t0)
	la $t1, nextcategory
	sw $t1, 4($t0) 
	la $t1, prevcategory
	sw $t1, 8($t0)
	la $t1, listcategories
	sw $t1, 12($t0)
	la $t1, delcategory
	sw $t1, 16($t0)
	la $t1, newobject
	sw $t1, 20($t0)
	la $t1, listobjects
	sw $t1, 24($t0)
	la $t1, delobject
	sw $t1, 28($t0)
	# -------------------------------
	
main_loop:
	
	# -------------------------------
	# Mostrar menu y leer opcion
	jal menu_display
	beqz $v0, main_end # Si la opcion es 0, terminar el programa
	addi $v0, $v0, -1 # Resta 1 a la opcion para obtener el indice del vector scheduler
	sll $v0, $v0, 2 # Multiplica por 4 para obtener la direccion de la funcion en schedv
	la $t0, schedv # Carga la direccion de schedv en $t0
	add $t0, $t0, $v0 # Suma la direccion de schedv con la direccion de la funcion
	lw $t1, ($t0) # Carga la direccion de la funcion en $t1 
	la $ra, main_ret # Guarda la direccion de retorno
  	jr $t1 # Salta a la funcion seleccionada
  	# -------------------------------
  	
main_ret:
	
	# -------------------------------
	j main_loop # Vuelve a mostrar el menu
	# -------------------------------
			
main_end:
	
	# -------------------------------
	done # Termina el programa
	# -------------------------------

menu_display:
	
	# -------------------------------
	# Mostar menu y leer opcion
	print_label(menu)
	read_int
	# -------------------------------
	
	# -------------------------------
	# Verificar si la opcion es valida
	bgt $v0, 8, menu_display_L1 # Si la opcion es mayor a 8, mostrar error 101
	bltz $v0, menu_display_L1 # Si la opcion es menor a 0, mostrar error 101
	jr $ra # Retornar la opcion
	# -------------------------------
	
menu_display_L1:
	
	# -------------------------------
	print_error(101) # Imprimir error 101
	j menu_display # Volver a mostrar el menu
	# -------------------------------
	
newcategory:

	# -------------------------------
	addiu $sp, $sp, -4 # Guardar el stack
	sw $ra, 4($sp) # Guardar la direccion de retorno
	la $a0, catName # Imprimir mensaje para pedir el nombre de la categoria
	jal getblock # Solicitar el nombre de la categoria
	move $a2, $v0 # Guardar la direccion del nombre de la categoria
	la $a0, cclist # Cargar la direccion de la lista de categorias
	li $a1, 0 # ID de la categoria
	jal addnode # Agregar la categoria a la lista
	lw $t0, wclist # Cargar la direccion de la categoria actual
	bnez $t0, newcategory_end # Si la categoria actual no es nula, terminar
	sw $v0, wclist # Guardar la direccion de la categoria en wclist
	# -------------------------------
	
newcategory_end:

	# -------------------------------
	li $v0, 0 # Retornar exito 
	lw $ra, 4($sp) # Recuperar la direccion de retorno
	addiu $sp, $sp, 4 # Restaurar el stack
	jr $ra # Retornar
	# -------------------------------

nextcategory:

	# -------------------------------
	lw $t0, wclist # Cargar la direccion de la categoria actual
	beqz $t0, er201 # Si no hay categorias, mostrar error 201
	# -------------------------------
	
	# -------------------------------
	lw $t1, wclist # Cargar la direccion de la categoria actual
	lw $t0, 12($t0) # Cargar la direccion de la categoria siguiente
	# -------------------------------
	
	# -------------------------------
	beq $t0, $t1, er202 # Si solo hay una categoria, mostrar error 202
	sw $t0, wclist # Guardar la direccion de la categoria siguiente en wclist
	lw $t0, 8($t0) # Cargar la direccion del nombre de la categoria
	print_label(selCat) # Imprimir mensaje de categoria seleccionada
	la $a0, 0($t0) # Cargar el nombre de la categoria
	li $v0, 4 # Syscall para imprimir una cadena
	syscall
	jr $ra # Retornar
	# -------------------------------
	
prevcategory:
	
	# -------------------------------
	lw $t0, wclist # Cargar la direccion de la categoria actual
	beqz $t0, er201 # Si no hay categorias, mostrar error 201
	# -------------------------------
	
	# -------------------------------
	lw $t1, wclist # Cargar la direccion de la categoria actual 
	lw $t0, 0($t0) # Cargar la direccion de la categoria anterior
	# -------------------------------
	
	# -------------------------------
	beq $t0, $t1, er202 # Si solo hay una categoria, mostrar error 202
	sw $t0, wclist # Guardar la direccion de la categoria anterior en wclist
	lw $t0, 8($t0) # Cargar la direccion del nombre de la categoria
	print_label(selCat) # Imprimir mensaje de categoria seleccionada
	la $a0, 0($t0) # Cargar el nombre de la categoria
	li $v0, 4 # Syscall para imprimir una cadena
	syscall
	jr $ra # Retornar
	# -------------------------------
	
listcategories:
	
	# -------------------------------
	lw $t0, wclist # Cargar la direccion de la categoria actual
	lw $t1, cclist # Cargar la direccion de la lista de categorias
	beqz $t1, er301 # Si no hay categorias, mostrar error 301
	lw $t2, cclist # Cargar la direccion de la lista de categorias
	j list_loop # Llamar a la funcion list_loop
	# -------------------------------
	
list_loop:

	# -------------------------------
	beq $t0, $t1, print_equal # Si la categoria actual es igual a la categoria de la lista, llamar a print_equal
	lw $a0, 8($t1) # Cargar la direccion del nombre de la categoria
	li $v0, 4 # Syscall para imprimir el nombre de la categoria
	syscall 
	lw $t1, 12($t1) # Cargar la direccion de la categoria siguiente
	beq $t1, $t2, list_loop_end # Si la categoria siguiente es igual a la primera, terminar
	j list_loop # Llamar a list_loop
	# -------------------------------
	
print_equal:
	
	# -------------------------------
	lw $t0, 8($t0) # Cargar la direccion del nombre de la categoria
	lw $t1, 12($t1) # Cargar la direccion de la categoria siguiente
	# -------------------------------
	
	# -------------------------------
	la $a0, indicador # Cargar el indicador
	li $v0, 4 # imprimir el indicador
	syscall
	la $a0, 0($t0) # Cargar el nombre de la categoria
	li $v0, 4 # imprimir el nombre de la categoria
	syscall
	beq $t1, $t2, list_loop_end # Si la categoria siguiente es igual a la primera, terminar
	j list_loop
	# -------------------------------
	
list_loop_end:
	
	# -------------------------------
	jr $ra # Retornar
	# -------------------------------
	
delcategory:

	# -------------------------------	
	addiu $sp, $sp, -4 # Guardar el stack
	sw $ra, 4($sp) # Guardar la direccion de retorno
	lw $t0, wclist # Cargar la direccion de la categoria actual
	beqz $t0, er401 # Si no hay categorias, mostrar error 401
	lw $t0, 4($t0) # Cargar la direccion de la lista de objetos de la categoria
	beqz $t0, del_empty_cat # Si no hay objetos en la categoria, llamar a del_empty_cat
	lw $t1, wclist # Cargar la direccion de la categoria actual
	la $a1, 4($t1) # Cargar la direccion de la lista de objetos de la categoria
	jal loop_del_obj # Llamar a loop_del_obj
	# -------------------------------
	
	# -------------------------------
	lw $ra, 4($sp) # Recuperar la direccion de retorno
	addiu $sp, $sp, 4 # Restaurar el stack
	jr $ra
	# -------------------------------
	
loop_del_obj:
	
	# -------------------------------
	lw $t2, 12($t0) # Cargar la direccion del proximo nodo
	add $a0, $0, $t0 # Cargar la direccion del nodo actual
	jal delnode # Llamar a delnode
	move $t0, $t2 # Cargar la direccion del proximo nodo
	beq $a0, $t0, del_empty_cat # Si el nodo actual es igual al proximo nodo, llamar a del_empty_cat
	j loop_del_obj # Llamar a loop_del_obj
	# -------------------------------
	
del_empty_cat:

	# -------------------------------
	lw $a0, wclist # Cargar la direccion de la categoria actual
	la $a1, cclist  # Cargar la direccion de la lista de categorias
	lw $t0, 12($a0) # Cargar la direccion de la categoria siguiente
	sw $t0, wclist # Guardar la direccion de la categoria siguiente en wclist
	jal delnode # Llamar a delnode
	print_label(success) # Imprimir mensaje de exito
	# -------------------------------
	
	# -------------------------------
	lw $t1, cclist # Cargar la direccion de la lista de categorias
	beqz $t1, reset_wclist # Si no hay categorias, llamar a reset_wclist
	# -------------------------------
	
	# -------------------------------
	lw $ra, 4($sp) # Recuperar la direccion de retorno
	addiu $sp, $sp, 4 # Restaurar el stack
	jr $ra
	# -------------------------------
	
reset_wclist:
	
	# -------------------------------
	sw $0, wclist # Reiniciar wclist
	lw $ra, 4($sp)	 # Recuperar la direccion de retorno
	addiu $sp, $sp, 4 # Restaurar el stack
	jr $ra
	# -------------------------------
	
newobject:

	# -------------------------------
	addiu $sp, $sp, -4 # Guardar el stack
	sw $ra, 4($sp) # Guardar la direccion de retorno
	lw $t0, wclist # Cargar la direccion de la categoria actual
	beqz $t0, er501 # Si no hay categoria, mostrar error 501
	# -------------------------------
	
	# -------------------------------
	la $a0, objName # Imprimir mensaje para pedir el nombre del objeto
	jal getblock # Solicitar el nombre del objeto
	move $a2, $v0 # Guardar la direccion del nombre del objeto
	lw $a0, wclist # Cargar la direccion de la categoria actual
	la $a0, 4($a0) # Cargar la direccion de la lista de objetos de la categoria
	lw $t0, 0($a0) # Cargar la direccion del primer nodo de la lista de objetos
	beqz $t0, insert_list # Si no hay nodos en la lista de objetos, llamar a insert_list
	lw $t0, 0($t0) # Cargar la direccion del primer nodo de la lista de objetos
	lw $t0, 4($t0) # Cargar el ID del primer nodo de la lista de objetos
	add $a1, $t0, 1  # Incrementar el ID del primer nodo de la lista de objetos
	# -------------------------------
	
make_node:
	
	# -------------------------------
	jal addnode # Llamar a addnode
	lw $t0, wclist # Cargar la direccion de la categoria actual
	la $t0, 4($t0) # Cargar la direccion de la lista de objetos de la categoria
	beqz $t0, first_node # Si no hay nodos en la lista de objetos, llamar a first_node
	# -------------------------------
	
end_insert_node:
	
	# -------------------------------		
	li $v0, 0 # Retornar exito
	lw $ra, 4($sp) # Recuperar la direccion de retorno
	addiu $sp, $sp, 4 # Restaurar el stack
	jr $ra
	# -------------------------------
	
insert_list:
	
	# -------------------------------	
	li $a1, 1 # ID del primer nodo de la lista de objetos
	j make_node # Llamar a make_node
	# -------------------------------
	
first_node:
	
	# -------------------------------
	sw $v0, 0($t0) # Guardar la direccion del primer nodo de la lista de objetos
	j end_insert_node # Llamar a end_insert_node
	# -------------------------------

listobjects:
	
	# -------------------------------
	lw $t0, wclist # Cargar la direccion de la categoria actual
	beqz $t0, er601 # Si no hay categoria, mostrar error 601
	lw $t0, 4($t0) # Cargar la direccion de la lista de objetos de la categoria
	beqz $t0, er602 # Si no hay objetos en la categoria, mostrar error 602
	# -------------------------------
	
	# -------------------------------
	lw $t1, wclist # Cargar la direccion de la categoria actual
	lw $t1, 4($t1) # Cargar la direccion de la lista de objetos de la categoria
	# -------------------------------
	
print_object:
	
	# -------------------------------
	la $a0, 4($t1) # Cargar la direccion del primer nodo de la lista de objetos
	lw $a0, 0($a0) # Cargar la direccion del primer nodo de la lista de objetos
	beq $a0, $a2, next # Si la direccion del nodo es igual a la direccion del primer nodo, llamar a next
	beqz $a0, print_object_end # Si no hay nodos en la lista de objetos, llamar a print_object_end
	li $v0, 1 # Syscall para imprimir un entero
	syscall	
	la $a0, separador # Cargar el separador
	li $v0, 4 # Syscall para imprimir una cadena
	syscall
	la $a0, 8($t1) # Cargar el ID del objeto
	lw $a0, 0($a0) # Cargar el ID del objeto
	li $v0, 4 # Syscall para imprimir un entero
	syscall
	# -------------------------------
	
next:
	
	# -------------------------------
	la $t2, 12($t1) # Cargar la direccion del proximo nodo
	lw $t2, 0($t2) # Cargar la direccion del proximo nodo
	beq $t2, $t0, print_object_end # Si la direccion del proximo nodo es igual a la direccion del primer nodo, llamar a print_object_end
	la $t1, 0($t2) # Cargar la direccion del proximo nodo
	j print_object # Llamar a print_object
	# -------------------------------
	
print_object_end:
	
	# -------------------------------
	jr $ra
	# -------------------------------
	
delobject:

	# -------------------------------
	addiu $sp, $sp, -4 # Guardar el stack
	sw $ra, 4($sp) # Guardar la direccion de retorno
	# -------------------------------
	
	# -------------------------------
	lw $t0, wclist # Cargar la direccion de la categoria actual
	beqz $t0, er701 # Si no hay categoria, mostrar error 701
	lw $t1, 4($t0) # Cargar la direccion de la lista de objetos de la categoria
	beqz $t1, er701 # Si no hay objetos en la categoria, mostrar error 701
	print_label(idObj) # Imprimir mensaje para pedir el ID del objeto
	read_int # Leer el ID del objeto
	add $a2, $0, $v0 # Guardar el ID del objeto
	lw $t3, 4($t0) # Cargar la direccion de la lista de objetos de la categoria
	# -------------------------------
	
del_obj_loop:

	# -------------------------------
	lw $t2, 4($t1) # Cargar la direccion del primer nodo de la lista de objetos
	beqz $t2, not_found # Si no hay nodos en la lista de objetos, llamar a not_found
	beq $t2, $a2, found # Si el ID del objeto es igual al ID del nodo, llamar a found
	lw $t1, 12($t1) # Cargar la direccion del proximo nodo
	beq $t3, $t1, not_found # Si la direccion del proximo nodo es igual a la direccion del primer nodo, llamar a not_found
	j del_obj_loop # Llamar a del_obj_loop
	# -------------------------------
	
found:

	# -------------------------------
	add $a0, $0, $t1 # Guardar la direccion del nodo
	add $a1, $t0, 4 # Guardar la direccion de la lista de objetos de la categoria
	jal delnode # Llamar a delnode
	print_label(success) # Imprimir mensaje de exito
	lw $ra, 4($sp) # Recuperar la direccion de retorno
	addiu $sp, $sp, 4 # Restaurar el stack
	jr $ra
	# -------------------------------
	
not_found:
	
	# -------------------------------
	print_label(objNotFound) # Imprimir mensaje de objeto no encontrado
	jr $ra
	# -------------------------------

addnode:
	
	# -------------------------------
	addi $sp, $sp, -8 # Guardar el stack
	sw $ra, 8($sp) # Guardar la direccion de retorno
	sw $a0, 4($sp) # Guardar el argumento a0
	jal smalloc # Solicitar un bloque de memoria
	sw $a1, 4($v0) # Guardar el ID en el nuevo nodo
	sw $a2, 8($v0) # Guardar la direccion del nombre en el nuevo nodo
	lw $a0, 4($sp) # Recuperar el argumento a0
	lw $t0, ($a0) # Cargar la direccion del primer nodo
	beqz $t0, addnode_empty_list # Si no hay nodos en la lista, llamar a addnode_empty_list
	# -------------------------------
	
addnode_to_end:
	
	# -------------------------------
	lw $t1, ($t0) # Cargar la direccion del ultimo nodo
	sw $t1, 0($v0) # Guardar la direccion del ultimo nodo en el nuevo nodo
	sw $t0, 12($v0) # Guardar la direccion del nuevo nodo en el ultimo nodo
	sw $v0, 12($t1) # Guardar la direccion del nuevo nodo en el primer nodo
	sw $v0, 0($t0) # Guardar la direccion del nuevo nodo en el ultimo nodo
	j addnode_exit # Llamar a addnode_exit
	# -------------------------------
	
addnode_empty_list:
	
	# -------------------------------
	sw $v0, ($a0) # Guardar la direccion del nuevo nodo en la lista
	sw $v0, 0($v0) # Guardar la direccion del nuevo nodo en el nuevo nodo
	sw $v0, 12($v0) # Guardar la direccion del nuevo nodo en el nuevo nodo
	# -------------------------------
	
addnode_exit:
	
	# -------------------------------
	lw $ra, 8($sp) # Recuperar la direccion de retorno
	addi $sp, $sp, 8 # Restaurar el stack
	jr $ra # Retornar
	# -------------------------------

delnode:

	# -------------------------------
	addi $sp, $sp, -8 # Guardar el stack
	sw $ra, 8($sp) # Guardar la direccion de retorno
	sw $a0, 4($sp) # Guardar el argumento a0
	lw $a0, 8($a0) # Cargar la direccion de la lista de objetos
	jal sfree # Llamar a sfree
	lw $a0, 4($sp) # Recuperar el argumento a0
	lw $t0, 12($a0) # Cargar la direccion del proximo nodo
	beq $a0, $t0, delnode_point_self # Si el nodo es el unico, llamar a delnode_point_self
	lw $t1, 0($a0) # Cargar la direccion del primer nodo
	sw $t1, 0($t0) # Guardar la direccion del primer nodo en el proximo nodo
	sw $t0, 12($t1) # Guardar la direccion del proximo nodo en el primer nodo
	lw $t1, 0($a1) # Cargar la direccion del primer nodo
	bne $a0, $t1, delnode_exit # Si el nodo no es el primer nodo, llamar a delnode_exit
	sw $t0, ($a1) # Guardar la direccion del proximo nodo en la lista
	j delnode_exit # Llamar a delnode_exit
	# -------------------------------
	
delnode_point_self:

	# -------------------------------
	sw $zero, ($a1) # Reiniciar la lista
	# -------------------------------
	
delnode_exit:

	# -------------------------------
	jal sfree # Llamar a sfree
	lw $ra, 8($sp) # Recuperar la direccion de retorno
	addi $sp, $sp, 8 # Restaurar el stack
	jr $ra
	# -------------------------------

getblock:
	
	# -------------------------------
	addi $sp, $sp, -4 # Guardar el stack
	sw $ra, 4($sp) # Guardar la direccion de retorno
	li $v0, 4 # Syscall para imprimir una cadena
	syscall 
	jal smalloc # Solicitar un bloque de memoria
	move $a0, $v0 # Guardar la direccion del bloque en a0
	li $a1, 16 # Cantidad de bytes a leer
	li $v0, 8 # Syscall para leer una cadena
	syscall
	move $v0, $a0 # Retornar la direccion del bloque
	lw $ra, 4($sp) # Recuperar la direccion de retorno
	addi $sp, $sp, 4 # Restaurar el stack
	jr $ra
	# -------------------------------

smalloc:
	
	# -------------------------------
	lw $t0, slist # Cargar la direccion de la lista de bloques libres
	beqz $t0, sbrk # Si no hay bloques libres, llamar a sbrk
	move $v0, $t0 # Retornar la direccion del bloque libre
	lw $t0, 12($t0) # Cargar la direccion del proximo bloque libre
	sw $t0, slist # Guardar la direccion del proximo bloque libre en slist
	jr $ra
	# -------------------------------
	
sbrk:
	
	# -------------------------------
	li $a0, 16 # Cantidad de bytes a solicitar
	li $v0, 9 # Syscall para solicitar memoria
	syscall 
	jr $ra
	# -------------------------------

sfree:

	# -------------------------------
	lw $t0, slist # Cargar la direccion de la lista de bloques libres
	sw $t0, 12($a0) # Guardar la direccion del primer bloque libre en el bloque a liberar
	sw $a0, slist # Guardar la direccion del bloque a liberar en slist
	jr $ra
	# -------------------------------

er201:

	# -------------------------------
	print_error(201) # Imprimir error 201
	print_label(label201)
	jr $ra
	# -------------------------------
	
er202:

	# -------------------------------
	print_error(202) # Imprimir error 202
	print_label(label202)
	jr $ra
	# -------------------------------
	
er301:
	
	# -------------------------------
	print_error(301) # Imprimir error 301
	print_label(label301)
	jr $ra
	# -------------------------------
	
er401:
	
	# -------------------------------
	print_error(401) # Imprimir error 401
	print_label(label401)
	jr $ra
	# -------------------------------
	
er501:

	# -------------------------------
	print_error(501) # Imprimir error 501
	print_label(label501)
	jr $ra
	# -------------------------------
	
er601:

	# -------------------------------
	print_error(601) # Imprimir error 601
	print_label(label601)
	jr $ra
	# -------------------------------
	
er602:

	# -------------------------------
	print_error(602) # Imprimir error 602
	print_label(label602)
	jr $ra
	# -------------------------------
	
er701:

	# -------------------------------
	print_error(701) # Imprimir error 701
	print_label(label701) 
	jr $ra
	# -------------------------------