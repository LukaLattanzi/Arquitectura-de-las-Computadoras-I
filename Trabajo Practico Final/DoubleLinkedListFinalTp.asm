# -------------------------------
.macro read_int 
	li $v0,5
	syscall
.end_macro

.macro print_label (%label) 
	la $a0, %label 
	li $v0, 4
	syscall
.end_macro

.macro done 
	li $v0,10
	syscall
.end_macro	

.macro print_error (%errno) 
	print_label(error)
	li $a0, %errno
	li $v0, 1
	syscall
	print_label(return)
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
	addi $v0, $v0, -1
	sll $v0, $v0, 2
	la $t0, schedv
	add $t0, $t0, $v0 # Suma la direccion de schedv con la direccion de la funcion
	lw $t1, ($t0)
	la $ra, main_ret # Guarda la direccion de retorno
  	jr $t1 # Salta a la funcion seleccionada
  	# -------------------------------
  	
main_ret:
	
	# -------------------------------
	j main_loop
	# -------------------------------
			
main_end:
	
	# -------------------------------
	done
	# -------------------------------

menu_display:
	
	# -------------------------------
	print_label(menu)
	read_int
	# -------------------------------
	
	# -------------------------------
	# Verificar si la opcion es valida
	bgt $v0, 8, menu_display_L1
	bltz $v0, menu_display_L1
	jr $ra
	# -------------------------------
	
menu_display_L1:
	
	# -------------------------------
	print_error(101)
	j menu_display
	# -------------------------------
	
newcategory:

	# -------------------------------
	addiu $sp, $sp, -4
	sw $ra, 4($sp) # Guardar la direccion de retorno en el stack
	la $a0, catName 
	jal getblock 
	move $a2, $v0
	la $a0, cclist 
	li $a1, 0
	jal addnode
	lw $t0, wclist 
	bnez $t0, newcategory_end 
	sw $v0, wclist 
	# -------------------------------
	
newcategory_end:

	# -------------------------------
	li $v0, 0 
	lw $ra, 4($sp)
	addiu $sp, $sp, 4
	jr $ra
	# -------------------------------

nextcategory:

	# -------------------------------
	lw $t0, wclist
	beqz $t0, er201 # Si no hay categorias, mostrar error 201
	# -------------------------------
	
	# -------------------------------
	lw $t1, wclist
	lw $t0, 12($t0)
	# -------------------------------
	
	# -------------------------------
	beq $t0, $t1, er202 # Si solo hay una categoria, mostrar error 202
	sw $t0, wclist
	lw $t0, 8($t0)
	print_label(selCat) # Imprimir mensaje de categoria seleccionada
	la $a0, 0($t0)
	li $v0, 4
	syscall
	jr $ra
	# -------------------------------
	
prevcategory:
	
	# -------------------------------
	lw $t0, wclist
	beqz $t0, er201 # Si no hay categorias, mostrar error 201
	# -------------------------------
	
	# -------------------------------
	lw $t1, wclist
	lw $t0, 0($t0)
	# -------------------------------
	
	# -------------------------------
	beq $t0, $t1, er202 # Si solo hay una categoria, mostrar error 202
	sw $t0, wclist
	lw $t0, 8($t0)
	print_label(selCat) # Imprimir mensaje de categoria seleccionada
	la $a0, 0($t0)
	li $v0, 4
	syscall
	jr $ra
	# -------------------------------
	
listcategories:
	
	# -------------------------------
	lw $t0, wclist
	lw $t1, cclist
	beqz $t1, er301 # Si no hay categorias, mostrar error 301
	lw $t2, cclist
	j list_loop
	# -------------------------------
	
list_loop:

	# -------------------------------
	beq $t0, $t1, print_equal # Si la categoria actual es igual a la categoria de la lista, llamar a print_equal
	lw $a0, 8($t1)
	li $v0, 4
	syscall 
	lw $t1, 12($t1)
	beq $t1, $t2, list_loop_end # Si la categoria siguiente es igual a la primera, terminar
	j list_loop
	# -------------------------------
	
print_equal:
	
	# -------------------------------
	lw $t0, 8($t0)
	lw $t1, 12($t1)
	# -------------------------------
	
	# -------------------------------
	la $a0, indicador 
	li $v0, 4
	syscall
	la $a0, 0($t0)
	li $v0, 4
	syscall
	beq $t1, $t2, list_loop_end # Si la categoria siguiente es igual a la primera, terminar
	j list_loop
	# -------------------------------
	
list_loop_end:
	
	# -------------------------------
	jr $ra
	# -------------------------------
	
delcategory:

	# -------------------------------	
	addiu $sp, $sp, -4
	sw $ra, 4($sp) # Guardar la direccion de retorno
	lw $t0, wclist
	beqz $t0, er401 # Si no hay categorias, mostrar error 401
	lw $t0, 4($t0)
	beqz $t0, del_empty_cat # Si no hay objetos en la categoria, llamar a del_empty_cat
	lw $t1, wclist
	la $a1, 4($t1)
	jal loop_del_obj
	# -------------------------------
	
	# -------------------------------
	lw $ra, 4($sp) 
	addiu $sp, $sp, 4
	jr $ra
	# -------------------------------
	
loop_del_obj:
	
	# -------------------------------
	lw $t2, 12($t0)
	add $a0, $0, $t0
	jal delnode
	move $t0, $t2 
	beq $a0, $t0, del_empty_cat
	j loop_del_obj
	# -------------------------------
	
del_empty_cat:

	# -------------------------------
	lw $a0, wclist
	la $a1, cclist
	lw $t0, 12($a0)
	sw $t0, wclist
	jal delnode
	print_label(success) # Imprimir mensaje de exito
	# -------------------------------
	
	# -------------------------------
	lw $t1, cclist 
	beqz $t1, reset_wclist
	# -------------------------------
	
	# -------------------------------
	lw $ra, 4($sp) 
	addiu $sp, $sp, 4
	jr $ra
	# -------------------------------
	
reset_wclist:
	
	# -------------------------------
	sw $0, wclist 
	lw $ra, 4($sp)
	addiu $sp, $sp, 4
	jr $ra
	# -------------------------------
	
newobject:

	# -------------------------------
	addiu $sp, $sp, -4
	sw $ra, 4($sp)
	lw $t0, wclist
	beqz $t0, er501 # Si no hay categoria, mostrar error 501
	# -------------------------------
	
	# -------------------------------
	la $a0, objName 
	jal getblock 
	move $a2, $v0
	lw $a0, wclist 
	la $a0, 4($a0) 
	lw $t0, 0($a0) 
	beqz $t0, insert_list # Si no hay nodos en la lista de objetos, llamar a insert_list
	lw $t0, 0($t0)
	lw $t0, 4($t0)
	add $a1, $t0, 1
	# -------------------------------
	
make_node:
	
	# -------------------------------
	jal addnode 
	lw $t0, wclist
	la $t0, 4($t0)
	beqz $t0, first_node # Si no hay nodos en la lista de objetos, llamar a first_node
	# -------------------------------
	
end_insert_node:
	
	# -------------------------------		
	li $v0, 0 
	lw $ra, 4($sp)
	addiu $sp, $sp, 4
	jr $ra
	# -------------------------------
	
insert_list:
	
	# -------------------------------	
	li $a1, 1
	j make_node
	# -------------------------------
	
first_node:
	
	# -------------------------------
	sw $v0, 0($t0)
	j end_insert_node
	# -------------------------------

listobjects:
	
	# -------------------------------
	lw $t0, wclist 
	beqz $t0, er601 # Si no hay categoria, mostrar error 601
	lw $t0, 4($t0)
	beqz $t0, er602 # Si no hay objetos en la categoria, mostrar error 602
	# -------------------------------
	
	# -------------------------------
	lw $t1, wclist
	lw $t1, 4($t1)
	# -------------------------------
	
print_object:
	
	# -------------------------------
	la $a0, 4($t1)
	lw $a0, 0($a0)
	beq $a0, $a2, next # Si la direccion del nodo es igual a la direccion del primer nodo, llamar a next
	beqz $a0, print_object_end # Si no hay nodos en la lista de objetos, llamar a print_object_end
	li $v0, 1
	syscall	
	la $a0, separador 
	li $v0, 4
	syscall
	la $a0, 8($t1)
	lw $a0, 0($a0)
	li $v0, 4
	syscall
	# -------------------------------
	
next:
	
	# -------------------------------
	la $t2, 12($t1)
	lw $t2, 0($t2)
	beq $t2, $t0, print_object_end # Si la direccion del proximo nodo es igual a la direccion del primer nodo, llamar a print_object_end
	la $t1, 0($t2)
	j print_object
	# -------------------------------
	
print_object_end:
	
	# -------------------------------
	jr $ra
	# -------------------------------
	
delobject:

	# -------------------------------
	addiu $sp, $sp, -4
	sw $ra, 4($sp)
	# -------------------------------
	
	# -------------------------------
	lw $t0, wclist
	beqz $t0, er701 # Si no hay categoria, mostrar error 701
	lw $t1, 4($t0) 
	beqz $t1, er701 # Si no hay objetos en la categoria, mostrar error 701
	print_label(idObj) 
	read_int 
	add $a2, $0, $v0 
	lw $t3, 4($t0)
	# -------------------------------
	
del_obj_loop:

	# -------------------------------
	lw $t2, 4($t1) 
	beqz $t2, not_found # Si no hay nodos en la lista de objetos, llamar a not_found
	beq $t2, $a2, found
	lw $t1, 12($t1) 
	beq $t3, $t1, not_found # Si la direccion del proximo nodo es igual a la direccion del primer nodo, llamar a not_found
	j del_obj_loop
	# -------------------------------
	
found:

	# -------------------------------
	add $a0, $0, $t1 
	add $a1, $t0, 4
	jal delnode
	print_label(success) # Imprimir mensaje de exito
	lw $ra, 4($sp) 
	addiu $sp, $sp, 4 
	jr $ra
	# -------------------------------
	
not_found:
	
	# -------------------------------
	print_label(objNotFound) # Imprimir mensaje de objeto no encontrado
	jr $ra
	# -------------------------------

addnode:
	
	# -------------------------------
	addi $sp, $sp, -8
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	jal smalloc # Solicitar un bloque de memoria
	sw $a1, 4($v0)
	sw $a2, 8($v0) 
	lw $a0, 4($sp) 
	lw $t0, ($a0)
	beqz $t0, addnode_empty_list # Si no hay nodos en la lista, llamar a addnode_empty_list
	# -------------------------------
	
addnode_to_end:
	
	# -------------------------------
	lw $t1, ($t0)
	sw $t1, 0($v0)
	sw $t0, 12($v0)
	sw $v0, 12($t1)
	sw $v0, 0($t0)
	j addnode_exit
	# -------------------------------
	
addnode_empty_list:
	
	# -------------------------------
	sw $v0, ($a0)
	sw $v0, 0($v0)
	sw $v0, 12($v0)
	# -------------------------------
	
addnode_exit:
	
	# -------------------------------
	lw $ra, 8($sp)
	addi $sp, $sp, 8 
	jr $ra
	# -------------------------------

delnode:

	# -------------------------------
	addi $sp, $sp, -8
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	lw $a0, 8($a0)
	jal sfree # Llamar a sfree
	lw $a0, 4($sp)
	lw $t0, 12($a0)
	beq $a0, $t0, delnode_point_self # Si el nodo es el unico, llamar a delnode_point_self
	lw $t1, 0($a0)
	sw $t1, 0($t0)
	sw $t0, 12($t1)
	lw $t1, 0($a1)
	bne $a0, $t1, delnode_exit # Si el nodo no es el primer nodo, llamar a delnode_exit
	sw $t0, ($a1)
	j delnode_exit
	# -------------------------------
	
delnode_point_self:

	# -------------------------------
	sw $zero, ($a1)
	# -------------------------------
	
delnode_exit:

	# -------------------------------
	jal sfree # Llamar a sfree
	lw $ra, 8($sp) 
	addi $sp, $sp, 8
	jr $ra
	# -------------------------------

getblock:
	
	# -------------------------------
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	li $v0, 4
	syscall 
	jal smalloc 
	move $a0, $v0
	li $a1, 16 
	li $v0, 8
	syscall
	move $v0, $a0 
	lw $ra, 4($sp) 
	addi $sp, $sp, 4
	jr $ra
	# -------------------------------

smalloc:
	
	# -------------------------------
	lw $t0, slist 
	beqz $t0, sbrk # Si no hay bloques libres, llamar a sbrk
	move $v0, $t0 
	lw $t0, 12($t0)
	sw $t0, slist
	jr $ra
	# -------------------------------
	
sbrk:
	
	# -------------------------------
	li $a0, 16 
	li $v0, 9
	syscall 
	jr $ra
	# -------------------------------

sfree:

	# -------------------------------
	lw $t0, slist 
	sw $t0, 12($a0)
	sw $a0, slist 
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