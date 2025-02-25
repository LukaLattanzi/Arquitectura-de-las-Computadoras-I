# El codigo proporcionado por el profesor con el simbolo "// PRO"
# El codigo realizo por el estudiante con el simbolo "// EST"

.macro read_int # Macro para leer un entero
	li $v0,5
	syscall
.end_macro

.macro print_label (%label) # Macro para imprimir un mensaje 
	la $a0, %label 
	li $v0, 4
	syscall
.end_macro

.macro done # Macro para finalizar el programa 
	li $v0,10
	syscall
.end_macro	

.macro print_error (%errno) # Macro para imprimir un error
	print_label(error)
	li $a0, %errno
	li $v0, 1
	syscall
	print_label(return)
.end_macro

.data # // PRO & EST
slist:	.word 0
cclist: .word 0 # circular category list
wclist: .word 0 # working category list
schedv: .space 32 # scheduler vector
menu:	
	.ascii "Colecciones de objetos categorizados\n"
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

.text
main: # // PRO & EST

	# Inicializa el vector guardando las direcciones de las funciones
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
	
main_loop: # // EST
	
	# Llama a menu_display, si el valor de retorno es 0 finaliza el programa
	jal menu_display
	beqz $v0, main_end

	# Calcula la direccion de la funcion seleccionada
	addi $v0, $v0, -1
	sll $v0, $v0, 2
	la $t0, schedv
	add $t0, $t0, $v0
	lw $t1, ($t0)

	# Guarda en $ra la direccion de main_ret y salta a la funcion seleccionada
	la $ra, main_ret 
  	jr $t1
  	
main_ret: # // EST
	
	# Vuelve al menu
	j main_loop
	
main_end: # // EST
	
	# Finaliza el programa
	done

menu_display: # // EST
	
    # Muestra el menu y lee el numero ingresado
	print_label(menu)
	read_int

    # Si el numero ingresado es mayor a 8 o menor a 0, muestra un error
	bgt $v0, 8, menu_display_L1
	bltz $v0, menu_display_L1

	# Retorna a la direccion almacenada en $ra (main_loop)
	jr $ra
	
menu_display_L1: # // EST
	
	# Muestra el error 101 y vuelve a mostrar el menu
	print_error(101)
	j menu_display
	
newcategory: # // PRO

	# Guarda en la pila la direccion del registro $ra (main_ret)
	addiu $sp, $sp, -4
	sw $ra, 4($sp)

	# Carga en $a0 la direccion de la cadena catName y llama a getblock
	la $a0, catName 
	jal getblock

	# Convierte la cadena a mayúsculas
    move $a0, $v0       # $a0 = dirección de la cadena leída
    jal to_upper       # se modifica la cadena en sitio

    # Mueve a $a2 la direccion de la cadena de caracteres obtenida
	move $a2, $v0

	# Carga en $a0 la direccion de cclist y en $a1 un 0 (para indicar que es una categoria)
	la $a0, cclist
	li $a1, 0

    # Llama a addnode para agregar la nueva categoria a la lista
	jal addnode

	# Carga en $t0 la direccion de wcList (working category list), si wclist no es NULL, salta a newcategory_end
	lw $t0, wclist 
	bnez $t0, newcategory_end

    # Si wclist es NULL, actualiza wclist con la direccion del nuevo nodo
	sw $v0, wclist
	
newcategory_end: # // PRO

	li $v0, 0
	lw $ra, 4($sp)
	addiu $sp, $sp, 4
	jr $ra

to_upper:

    move $t0, $a0       # $t0 apunta al inicio de la cadena

to_upper_loop:

    lb $t1, 0($t0)      # Carga el carácter actual
    beq $t1, $zero, to_upper_end   # Si es fin de cadena, termina
    li $t2, 97          # ASCII de 'a'
    blt $t1, $t2, skip_conversion  # Si es menor que 'a', no se modifica
    li $t2, 122         # ASCII de 'z'
    bgt $t1, $t2, skip_conversion  # Si es mayor que 'z', no se modifica
    addi $t1, $t1, -32  # Convierte a mayúscula (por ejemplo, 'a'->'A')
    sb $t1, 0($t0)      # Guarda el carácter convertido

skip_conversion:

    addiu $t0, $t0, 1   # Pasa al siguiente carácter
    j to_upper_loop

to_upper_end:

    jr $ra             # Retorna a la función que llamó

nextcategory: # // EST

    # Carga en $t0 la direccion de wclist (working category list), si $t0 es NULL (no hay categorias), muestra un error
	lw $t0, wclist
	beqz $t0, er201

	# Carga en $t1 la direccion de wclist y en $t0 el contenido de la direccion 12 de wclist (siguiente categoria), si $t0 es igual a $t1 (no hay siguiente categoria), muestra un error
	lw $t1, wclist
	lw $t0, 12($t0)
	beq $t0, $t1, er202

    # Actualiza wclist con la direccion de la siguiente categoria, carga en $t0 el contenido de la direccion 8 de la nueva categoria (nombre de la categoria) y muestra el mensaje
	sw $t0, wclist
	lw $t0, 8($t0) 
	print_label(selCat)

	# Imprime el nombre de la categoria seleccionada
	la $a0, 0($t0)
	li $v0, 4
	syscall

	# Vuelve a la direccion de retorno (main_ret)
	jr $ra
	
prevcategory: # // EST
	
    # Carga en $t0 la direccion de wclist (working category list), si $t0 es NULL (no hay categorias), muestra un error
	lw $t0, wclist
	beqz $t0, er201

    # Carga en $t1 la direccion de wclist y en $t0 el contenido de la direccion 0 de wclist (categoria anterior), si $t0 es igual a $t1 (no hay categoria anterior), muestra un error
	lw $t1, wclist
	lw $t0, 0($t0)
	beq $t0, $t1, er202

    # Actualiza wclist con la direccion de la siguiente categoria, carga en $t0 el contenido de la direccion 8 de la nueva categoria (nombre de la categoria) y muestra el mensaje
	sw $t0, wclist
	lw $t0, 8($t0)
	print_label(selCat)

	# Imprime el nombre de la categoria seleccionada
	la $a0, 0($t0)
	li $v0, 4
	syscall

	# Vuelve a la direccion de retorno (main_ret)
	jr $ra
	
listcategories: # // EST
	
    # Carga en $t0 la direccion de wclist (working category list)
	lw $t0, wclist

	# Carga en $t1 la direccion de cclist (circular category list), si $t1 es NULL (no hay categorias), muestra un error
	lw $t1, cclist
	beqz $t1, er301

    # Carga en $t2 la direccion de cclist y salta a list_loop para comenzar a listar las categorias
	lw $t2, cclist
	j list_loop
	
list_loop: # // EST

	# si $t0 (wclist) es igual a $t1 (cclist) salta a print_equal
	beq $t0, $t1, print_equal

	# Carga el $a0 la direccion 8 de cclist (El nombre de la categoria) y lo imprime
	lw $a0, 8($t1)
	li $v0, 4
	syscall

	# Carga en $t1 la direccion 12 de cclist (La direccion del siguiente nodo), si es igual a $t2 (cclist) salta a list_loop_end, sino salta a list_loop
	lw $t1, 12($t1)
	beq $t1, $t2, list_loop_end
	j list_loop
	
print_equal: # // EST
	
	# Carga en $t0 la direccion 8 de wclist (El nombre de la categoria) y en $t1 la direccion 12 de cclist (La direccion del siguiente nodo)
	lw $t0, 8($t0)
	lw $t1, 12($t1)

	# Imprime el indicador
	la $a0, indicador 
	li $v0, 4
	syscall

	# Imprime el nombre de la categoria
	la $a0, 0($t0)
	li $v0, 4
	syscall

    # Si $t1 es igual a $t2 (cclist), salta a list_loop_end, sino salta a list_loop
	beq $t1, $t2, list_loop_end
	j list_loop
	
list_loop_end: # // EST
	
	# Vuelve a la direccion de retorno (main_ret)
	jr $ra
	
delcategory: # // EST

	# Guarda en la pila la direccion del registro $ra (main_ret)
	addiu $sp, $sp, -4
	sw $ra, 4($sp)

	# Carga en $t0 la direccion de wclist (working category list) y si es NULL muestra un error
	lw $t0, wclist
	beqz $t0, er401

	# Carga en $t0 la direccion 4 de wclist (La direccion con la lista de la categoria) y si esta vacia salta a del_empty_cat
	lw $t0, 4($t0)
	beqz $t0, del_empty_cat

	lw $t1, wclist
	la $a1, 4($t1)
	jal loop_del_obj
	lw $ra, 4($sp) 
	addiu $sp, $sp, 4
	jr $ra
	
loop_del_obj: # // EST
	
	lw $t2, 12($t0)
	add $a0, $0, $t0
	jal delnode
	move $t0, $t2 
	beq $a0, $t0, del_empty_cat
	j loop_del_obj
	
del_empty_cat: # // EST

	# Carga en $a0 la direccion de wclist (working category list) y en $a1 la direccion donde se encuentra cclist (circular category list) 
	lw $a0, wclist
	la $a1, cclist

	# Carga en $t0 la direccion 12 de wclist (La direccion del siguiente nodo), y guarda este valor en wclist
	lw $t0, 12($a0)
	sw $t0, wclist

	# Salta a delnode para eliminar el nodo
	jal delnode

	# Imprime el mensaje de exito
	print_label(success)

	# Carga en $t1 la direccion de cclist, si es NULL salta a reset_wclist
	lw $t1, cclist 
	beqz $t1, reset_wclist

	# Carga en $ra el registro de retorno (main_ret) y vuelve a la direccion de retorno
	lw $ra, 4($sp) 
	addiu $sp, $sp, 4
	jr $ra
	
reset_wclist: # // EST
	
	# Guarda en $0 (NULL) en wclist
	sw $0, wclist 

	# Recupera la direccion de retorno (main_ret) y vuelve a la direccion de retorno
	lw $ra, 4($sp)
	addiu $sp, $sp, 4
	jr $ra
	
newobject: # // EST

	# Guarda en la pila la direccion del registro $ra (main_ret)
	addiu $sp, $sp, -4
	sw $ra, 4($sp)

	# Carga en $t0 la direccion de wclist (working category list) y si es NULL muestra un error
	lw $t0, wclist
	beqz $t0, er501

	# Carga en $a0 la direccion donde se encuentra objName y llama a getblock
	la $a0, objName 
	jal getblock

	# Mueve a $a2 la direccion obtenida en getblock
	move $a2, $v0

	# Carga en $a0 la direccion de wclist 
	lw $a0, wclist

	# Ajusta $a0 para que apunte a la direccion wclist + 4 (la direccion de la lista de la categoria)
	la $a0, 4($a0) 

	# Carga en $t0 el contenido de la direccion apuntada por $a0 (la direccion del primer nodo de la lista de la categoria)
	lw $t0, 0($a0)

	# Si $t0 es NULL (No tiene nodos en la lista de la categoria), salta a insert_list
	beqz $t0, insert_list

	# Carga en $t0 la direccion del siguiente nodo en la lista de la categoria
	lw $t0, 0($t0)

	# Carga en $t0 el contenido de la direccion 4 del nodo actual (probablemente el siguiente nodo)
	lw $t0, 4($t0)

	# Incrementa el valor en $t0 en 1 y lo almacena en $a1
	add $a1, $t0, 1
	
make_node: # // EST
	
	# Salta a addnode para agregar el nodo
	jal addnode

	# Carga en $t0 la direccion de wclist y ajusta $t0 para que apunte a la direccion wclist + 4 (la direccion de la lista de la categoria)
	lw $t0, wclist
	la $t0, 4($t0)

	# Si $t0 es NULL (No tiene nodos en la lista de la categoria), salta a first_node
	beqz $t0, first_node
	
end_insert_node: # // EST

	# Establece $v0 a 0, recupera la direccion de retorno (main_ret) y vuelve a la direccion de retorno
	li $v0, 0 
	lw $ra, 4($sp)
	addiu $sp, $sp, 4
	jr $ra
	
insert_list: # // EST
	
	# Carga en $a1 el valor 1 y salta a make_node
	li $a1, 1
	j make_node
	 
first_node: # // EST
	
    # Guarda la direccion del nuevo nodo en la lista de la categoria y alta a end_insert_node para finalizar la inserción
	sw $v0, 0($t0)
	j end_insert_node

listobjects: # // EST
	
	# Carga en $t0 la direccion de wclist (working category list) y si es NULL (No hay categorias), muestra un error
	lw $t0, wclist 
	beqz $t0, er601
	
	# Carga en $t0 la direccion del primer nodo de la lista de la categoria, si $t0 es NULL (la lista de la categoria esta vacia), muestra un error 
	lw $t0, 4($t0)
	beqz $t0, er602

	# Carga en $t1 la direccion de wclist (working category list) para luego cargar la direccion del primer nodo de la lista de la categoria
	lw $t1, wclist
	lw $t1, 4($t1)
	
print_object: # // EST
	
	# Carga en $a0 el contenido de la direccion 4 del nodo actual (nombre del objeto)
	la $a0, 4($t1)
	lw $a0, 0($a0)

	# Si $a0 es igual a $a2 (el objeto buscado), salta a next
	beq $a0, $a2, next

    # Si $a0 es NULL (fin de la lista), salta a print_object_end
	beqz $a0, print_object_end

    # Imprime el valor en $a0 (nombre del objeto)
	li $v0, 1
	syscall

	# Imprime el separador
	la $a0, separador 
	li $v0, 4
	syscall

	# Carga en $a0 el contenido de la direccion 8 del nodo actual (información adicional del objeto)
	la $a0, 8($t1)
	lw $a0, 0($a0)

    # Imprime la información adicional del objeto
	li $v0, 4
	syscall
	
next: # // EST

    # Carga en $t2 la direccion del siguiente nodo (contenido de la direccion 12 del nodo actual)
	la $t2, 12($t1)
	lw $t2, 0($t2)

    # Si $t2 es igual a $t0 (fin de la lista), salta a print_object_end
	beq $t2, $t0, print_object_end

    # Actualiza $t1 para que apunte al siguiente nodo
	la $t1, 0($t2)

	# Salta a print_object para imprimir el siguiente objeto
	j print_object
	
print_object_end: # // EST
	
	# Retorna a la direccion almacenada en $ra (main_ret)
	jr $ra
	
delobject: # // EST

    # Reserva espacio en la pila y guarda la direccion de retorno (main_ret)
	addiu $sp, $sp, -4
	sw $ra, 4($sp)

    # Carga en $t0 la direccion de wclist (working category list), si $t0 es NULL (no hay categorias), muestra un error
	lw $t0, wclist
	beqz $t0, er701

    # Carga en $t1 la direccion del primer nodo de la lista de la categoria, si $t1 es NULL (la lista de la categoria está vacía), salta a er701
	lw $t1, 4($t0) 
	beqz $t1, er701

	# Muestra el mensaje para ingresar el ID del objeto a borrar, lee el ID del objeto a borrar y lo guarda en $a2
	print_label(idObj) 
	read_int
	add $a2, $0, $v0

	# Carga en $t3 la direccion del primer nodo de la lista de la categoria
	lw $t3, 4($t0)
	
del_obj_loop: # // EST

    # Carga en $t2 el ID del objeto actual (contenido de la direccion 4 del nodo actual)
	lw $t2, 4($t1) 

	# Si $t2 es NULL (fin de la lista), salta a not_found, y si $t2 es igual a $a2 (el objeto buscado), salta a found
	beqz $t2, not_found
	beq $t2, $a2, found

    # Carga en $t1 la direccion del siguiente nodo en la lista de la categoria, y si $t3 es igual a $t1 (fin de la lista), salta a not_found
	lw $t1, 12($t1) 
	beq $t3, $t1, not_found

	# Salta a del_obj_loop para continuar buscando
	j del_obj_loop
	
found: # // EST

	# Prepara los argumentos para llamar a delnode
	add $a0, $0, $t1 
	add $a1, $t0, 4

	# Llama a delnode para borrar el nodo
	jal delnode

    # Muestra el mensaje de éxito
	print_label(success)

	# Recupera la direccion de retorno (main_ret) y vuelve a la direccion de retorno
	lw $ra, 4($sp) 
	addiu $sp, $sp, 4 
	jr $ra
	
not_found: # // EST
	
	# Muestra el mensaje de error y vuelve a la direccion de retorno (main_ret)
	print_label(objNotFound)
	jr $ra

addnode: # // PRO
	
	# a0: list address | a1: NULL if category, node address if object | v0: node address added

	addi $sp, $sp, -8
	sw $ra, 8($sp)
	sw $a0, 4($sp)

	# Salta a smalloc para obtener un bloque de memoria
	jal smalloc

	# Guarda el contenido del nodo en la memoria asignada
	sw $a1, 4($v0) 
	sw $a2, 8($v0) 

	# Restaura la direccion de la lista desde la pila
	lw $a0, 4($sp) 

	# Carga el contenido del primer nodo
	lw $t0, ($a0) 

	# Si la lista está vacía, salta a addnode_empty_list
	beqz $t0, addnode_empty_list

addnode_to_end: # // PRO

    # Carga la direccion del último nodo en $t1
    lw $t1, ($t0) # Last node address

    # Actualiza los punteros prev y next del nuevo nodo
    sw $t1, 0($v0) # Establece el puntero prev del nuevo nodo al último nodo
    sw $t0, 12($v0) # Establece el puntero next del nuevo nodo al nodo actual

    # Actualiza los punteros prev y next del último nodo y del primer nodo
    sw $v0, 12($t1) # Establece el puntero next del último nodo al nuevo nodo
    sw $v0, 0($t0) # Establece el puntero prev del primer nodo al nuevo nodo

    # Salta a la salida de la función addnode
    j addnode_exit
	
addnode_empty_list: # // PRO
	
    # Guarda en el primer nodo la dirección de sí mismo (lista circular)
 	sw $v0, ($a0) # Establece el primer nodo de la lista
    sw $v0, 0($v0) # Establece el puntero prev del nuevo nodo a sí mismo
    sw $v0, 12($v0) # Establece el puntero next del nuevo nodo a sí mismo
	
addnode_exit: # // PRO
	
    # Restaura la dirección de retorno desde la pila y ajusta el puntero de pila
	lw $ra, 8($sp)
	addi $sp, $sp, 8 
	jr $ra

delnode: # // PRO

	# a0: node address to delete | a1: list address where node is deleted

    # Restaura la dirección de retorno desde la pila y ajusta el puntero de pila
	addi $sp, $sp, -8
	sw $ra, 8($sp)
	sw $a0, 4($sp)

    # Obtiene la dirección del bloque de memoria del nodo a eliminar
	lw $a0, 8($a0)
	
	# Llama a sfree para liberar el bloque de memoria
	jal sfree

	# Restaura el argumento $a0 desde la pila
	lw $a0, 4($sp)

    # Obtiene la dirección del siguiente nodo del nodo a eliminar, si el nodo a eliminar se apunta a sí mismo, salta a delnode_point_self
	lw $t0, 12($a0)
	beq $a0, $t0, delnode_point_self

    # Obtiene la dirección del nodo previo al nodo a eliminar y actualiza el puntero prev del siguiente nodo para que apunte al nodo previo
	lw $t1, 0($a0)
	sw $t1, 0($t0)

	# Actualiza el puntero next del nodo previo para que apunte al siguiente nodo
	sw $t0, 12($t1) 

    # Obtiene la dirección del primer nodo de la lista, si el nodo a eliminar no es el primer nodo, salta a delnode_exit
	lw $t1, 0($a1)
	bne $a0, $t1, delnode_exit

	# Si el nodo a eliminar es el primer nodo, actualiza la lista para que apunte al siguiente nodo
	sw $t0, ($a1)

	# Salta a delnode_exit
	j delnode_exit
	
delnode_point_self: # // PRO

	# Si solo hay un nodo en la lista, establece la lista a NULL
	sw $zero, ($a1)

delnode_exit: # // PRO

	# Llama a sfree para liberar el bloque de memoria del nodo
	jal sfree

	lw $ra, 8($sp) 
	addi $sp, $sp, 8
	jr $ra

getblock: # // PRO
	
	# a0: msg to ask | a1: block address allocated with string

	# Guarda en la pila la direccion del registro $ra (newcategory)
	addi $sp, $sp, -4
	sw $ra, 4($sp)

	# Imprime el mensaje (catName)
	li $v0, 4
	syscall

	# Salta a smalloc para obtener un bloque de memoria, y guarda la direccion en $a0
	jal smalloc
	move $a0, $v0

	# Syscall para leer una cadena de caracteres de maximo 16 bytes (15 caracteres)
	li $a1, 16 
	li $v0, 8
	syscall

	# Mueve a $v0 la direccion de la cadena de caracteres
 	move $v0, $a0

	# Carga el registro $ra con la direccion de retorno (newcategory) y restaura la pila
	lw $ra, 4($sp) 
	addi $sp, $sp, 4
	jr $ra

smalloc: # // PRO

	# Carga en $t0 la direccion de slist y si es slist es 0 (NULL) llama a sbrk
	lw $t0, slist 
	beqz $t0, sbrk

	# Mueve a $v0 la direccion de slist y carga en $t0 la direccion de la siguiente lista
	move $v0, $t0 
	lw $t0, 12($t0)
	sw $t0, slist

	# Vuelve a la direccion de retorno (getblock)
	jr $ra
	
sbrk: # // PRO
	
	# Llama al syscall sbrk y guarda un espacio de 16 bytes (4 palabras) que es el tamaño de un nodo
	li $a0, 16
	li $v0, 9
	syscall

	# Vuelve a la direccion de retorno (getblock)
	jr $ra

sfree: # // PRO

	lw $t0, slist 
	sw $t0, 12($a0)
	sw $a0, slist # $a0 node address in unused list
	jr $ra

er201: # // EST

	print_error(201)
	print_label(label201)
	jr $ra
	
er202: # // EST

	print_error(202)
	print_label(label202)
	jr $ra
	
er301: # // EST
	
	print_error(301)
	print_label(label301)
	jr $ra
	
er401: # // EST
	
	print_error(401)
	print_label(label401)
	jr $ra
	
er501: # // EST

	print_error(501)
	print_label(label501)
	jr $ra
	
er601: # // EST

	print_error(601)
	print_label(label601)
	jr $ra
	
er602: # // EST

	print_error(602)
	print_label(label602)
	jr $ra
	
er701: # // EST

	print_error(701)
	print_label(label701) 
	jr $ra