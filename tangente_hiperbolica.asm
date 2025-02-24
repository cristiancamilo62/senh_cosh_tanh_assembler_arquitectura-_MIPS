.data
prompt:      .asciiz "Ingrese el valor de x: "
result_msg:  .asciiz "El seno hiperbólico de x es: "
result:      .float 0.0   # Resultado del cálculo
one:         .float 1.0   # Constante 1.0 en punto flotante
two:         .float 2.0   # Constante 2.0 en punto flotante

.text
.globl main
main:
    # Pedir el valor de x por consola
    li $v0, 4
    la $a0, prompt
    syscall

    li $v0, 6       # Syscall para leer un float
    syscall
    # El valor leído ya se encuentra en $f0

    # Calcular e^x usando la serie de Taylor (10 términos)
    l.s $f1, one    # e^x = 1.0
    l.s $f2, one    # término = 1.0
    li  $t0, 1     # contador n = 1
    li  $t2, 500    # número de términos

calc_exp:
    mul.s $f2, $f2, $f0   # término *= x
    mtc1 $t0, $f3         # convertir n a float
    cvt.s.w $f3, $f3
    div.s $f2, $f2, $f3   # término /= n
    add.s $f1, $f1, $f2   # e^x += término
    addi $t0, $t0, 1      # n += 1
    blt  $t0, $t2, calc_exp  # mientras n < 10
    # Si $t0 >= 10, salta a end_calc_exp

end_calc_exp:
    # Calcular e^-x usando la serie de Taylor (10 términos)
    neg.s $f5, $f0        # -x
    l.s $f6, one          # e^-x = 1.0
    l.s $f7, one          # término = 1.0
    li  $t1, 1           # contador n = 1

calc_exp_neg:
    mul.s $f7, $f7, $f5   # término *= -x
    mtc1 $t1, $f8         # convertir n a float
    cvt.s.w $f8, $f8
    div.s $f7, $f7, $f8   # término /= n
    add.s $f6, $f6, $f7   # e^-x += término
    addi $t1, $t1, 1      # n += 1
    blt  $t1, $t2, calc_exp_neg  # mientras n < 10

end_calc_exp_neg:
    # Calcular (e^x - e^-x) / 2
    sub.s $f9, $f1, $f6   # e^x - e^-x
    add.s $f13, $f1, $f6   # e^x + e^-x
    l.s $f10, two        # cargar 2.0
    div.s $f11, $f9, $f10  # (e^x - e^-x) / 2
    div.s $f14, $f13, $f10  # (e^x + e^-x) / 2

    div.s $f15,$f11,$f14
    # Guardar el resultado en memoria
    la $t5, result
    swc1 $f15, 0($t5)

    # Mostrar el resultado en consola
    li $v0, 4
    la $a0, result_msg
    syscall

    li $v0, 2
    mov.s $f12, $f15
    syscall

    # Salir del programa
    li $v0, 10
    syscall
