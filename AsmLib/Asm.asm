;/////////////////////////////////////////////////////////////////////
;//  TEMAT PROJEKTU: ROZMYCIE GAUSSA                                //
;//-----------------------------------------------------------------//
;//  OPIS ALGORYTMU: jest filtrem dolnoprzepustowym, który mnozy    //
;//  kazdy pixel i jego otoczenie przez jadro filtra uzyskane na    //
;//  podstawie rozkladu normalnego                                  //
;//-----------------------------------------------------------------//
;//  Autor oraz data wykonania: Aleksandra Tlalka 24.01.2022r sem.5 //
;//  Wersja programu: 1.0                                           //
;//-----------------------------------------------------------------//
;//  Dane wejsciowe:												//
;//        input - tablica wejsciowa								//
;//        output - tablica wyjsciowa								//
;//        imageWidth - szerokosc obrazu w pixelach					//
;//        imageHeight - wysokosc obrazu w pixelach       			//
;/////////////////////////////////////////////////////////////////////

.data
.code
MyProc1 proc EXPORT
	local imageWidth:	QWORD	;szerokosc obrazu w pixelach
	local imageHeight:	QWORD	;wysokosc obrazu w pixelach
	local input:		QWORD	;tablica wejsciowa
	local output:		QWORD	;tablica wyjsciowa
	local RedValue: 	SDWORD	;wartosc RGB koloru czerwonego
    local GreenValue:	SDWORD	;wartosc RGB koloru zielonego
    local BlueValue:	SDWORD	;wartosc RGB koloru niebieskiego
	local pozX:			QWORD	;pozycja x pixela
	local pozY:			QWORD	;pozycja y pixela
	local x_max:		QWORD	;maksymalna pozycja x
	local y_max:		QWORD	;maksymalna pozycja y
	local two:			BYTE	;liczba 2 do mnozenia
	local four:			BYTE	;liczba 4 do mnozenia
	
	;zapisanie rejestrow 
	push RBP
    push RDI
    push RSP
	push RSI
	push RBX
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	
	;wyzerowanie zmiennych
	xor rax, rax		
	mov RedValue, eax	
	mov GreenValue, eax	
	mov BlueValue, eax	
	mov pozX, rax			
	mov pozY, rax			
	
	mov two, 2					;przypisanie two do mnozenia
	mov four, 4					;przypisanie four do mnozenia
	mov input, rcx				;przypisanie tablicy wejsciowej z parametru funkcji
	mov output, rdx				;przypisanie tablicy wyjsciowej z parametru funkcji
	mov rax, r8					;wczytanie szerokosci do rax
	mov rbx, 3					;wczytanie 3 do rbx
	mul rbx						;iloczyn szerokosci i 3
	mov imageWidth, rax			;przypisanie szerokosci obrazu (szerokosc obrazu w pixelach * 3)
	mov imageHeight, r9			;przypisanie wysokosci obrazu (w pixelach)

	mov rax, imageWidth
	sub rax, 6		
	mov x_max, rax				;ustawienie maxymalnego pixela(szerokosc) jako szerokosc - 6 pixeli
	mov rax, imageHeight
	sub rax, 2
	mov y_max, rax				;ustawienie maxymalnego pixela(wysokosc) jako wysokosc - 2 pixele

PETLAY:							;petla po pozY pixela
	inc pozY					;inkrementacja pozY
	mov pozX, 0					;wyzerowanie pozX

PETLAX:							;petla po pozX pixela
	add pozX, 3					;przesuniecie pozX o 3

	;wyzerowanie wartosci RGB
	xor rax, rax			;Wyzerowanie rax
	mov RedValue, eax	;Wyzerowanie RedValue
	mov GreenValue, eax	;Wyzerowanie GreenValue
	mov BlueValue, eax	;Wyzerowanie BlueValue

	;sumowanie pixeli jadra z wagami
	
	;pozycja pixela wzgledem srodkowego:
	;			x - -
	;			- - -
	;			- - -

	mov rax, pozY			;Wczytanie aktualnej pozycji Y pixela do rax	
	dec rax					;Dekrementacja rax o 1(Poniewaz chcemy dane z lewego gornego pixela wzgledem obliczanego pixela)
	mul imageWidth			;Wpisanie iloczynu imageWidth(szerokosci obrazu) oraz pozycji Y pixela do rax
	add rax, pozX			;Dodanie pozycji X pixela do rax
	sub rax, 3				;Odjecie 3 od rax(Poniewaz chcemy dane z lewego gornego pixela wzgledem obliczanego pixela)
	add rax, input			;Dodanie adresu pierwszego elementu tablicy INPUT do rax
	mov rbx,rax				;Przypisanie aktualnej wartosci rax do rbx
	xor rax, rax			;Wyzerowanie rax
	mov AL, [rbx]			;Przypisanie wartosci koloru Red(lewego gornego pixela wzgledem obliczanego pixela) do AL
	add RedValue, eax	    ;Dodanie wartosci koloru Red do RedValue
	xor rax,rax				;Wyzerowanie rax
	add rbx, 1				;Inkrementacja rbx - aby przejsc do koloru Green
	mov AL, [rbx]			;Przypisanie wartosci koloru Green(lewego gornego pixela wzgledem obliczanego pixela) do AL
	add GreenValue, eax	    ;Dodanie wartosci koloru Green do GreenValue
	xor rax, rax			;Wyzerowanie rax
	add rbx, 1				;Inkrementacja rbx - aby przejsc do koloru Blue
	mov AL, [rbx]			;Przypisanie wartosci koloru Blue(lewego gornego pixela wzgledem obliczanego pixela) do AL
	add BlueValue, eax	    ;Dodanie wartosci koloru Blue do BlueValue

	;pozycja pixela wzgledem srodkowego:
	;			- x -
	;			- - -
	;			- - -
	xor rax, rax
	add rbx, 1
	mov AL, [rbx]
	mul two
	add RedValue, eax
	xor rax, rax
	add rbx, 1
	mov AL, [rbx]
	mul two
	add GreenValue, eax
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	mul two
	add BlueValue, eax


	;pozycja pixela wzgledem srodkowego:
	;			- - x
	;			- - -
	;			- - -
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	add RedValue, eax
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	add GreenValue, eax
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	add BlueValue, eax


	;pozycja pixela wzgledem srodkowego:
	;			- - -
	;			x - -
	;			- - -
	add rbx, imageWidth
	sub rbx, 8
	xor rax, rax
	mov AL, [rbx]
	mul two
	add RedValue, eax
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	mul two
	add GreenValue, eax
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	mul two
	add BlueValue, eax


	;pozycja pixela wzgledem srodkowego:
	;			- - -
	;			- x -
	;			- - -
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	mul four
	add RedValue, eax
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	mul four
	add GreenValue, eax
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	mul four
	add BlueValue, eax


	;pozycja pixela wzgledem srodkowego:
	;			- - -
	;			- - x
	;			- - -
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	mul two
	add RedValue, eax
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	mul two
	add GreenValue, eax
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	mul two
	add BlueValue, eax


	;pozycja pixela wzgledem srodkowego:
	;			- - -
	;			- - -
	;			x - -
	add rbx, imageWidth
	sub rbx, 8
	xor rax, rax
	mov AL, [rbx]												
	add RedValue, eax																			
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	add GreenValue, eax
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	add BlueValue, eax


	;pozycja pixela wzgledem srodkowego:
	;			- - -
	;			- - -
	;			- x -
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	mul two
	add RedValue, eax
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	mul two
	add GreenValue, eax
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	mul two
	add BlueValue, eax


	;pozycja pixela wzgledem srodkowego:
	;			- - -
	;			- - -
	;			- - x
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	add RedValue, eax
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	add GreenValue, eax
	xor rax,rax
	add rbx, 1
	mov AL, [rbx]
	add BlueValue, eax

	;obliczenie wartosci red pixela wynikowego
	
	mov eax,RedValue			;wpisanie RedValue do eax
	cvtsi2ss xmm0, eax			;wpisanie eax(suma 16 wag wartosci koloru red) do xmm0
	mov eax, 16					;wpisanie 16 do eax
	cvtsi2ss xmm1, eax			;wpisanie eax(16) do xmm1
	divss xmm0, xmm1			;dzielenie sumy 16 wag wartosci koloru red przez ilosc zsumowanych elementow(9)
	cvtss2si eax, xmm0			;wpisanie wyniku do eax
	mov RedValue,eax			;wpisanie wyniku dzielenia do zmiennej RedValue
    
	;obliczenie wartosci green pixela wynikowego

	mov eax,GreenValue			;wpisanie GreenValue do eax
    cvtsi2ss xmm0, eax			;wpisanie eax(suma 16 wag wartosci koloru green) do xmm0
	mov eax, 16					;wpisanie 16 do eax
	cvtsi2ss xmm1, eax			;wpisanie eax(16) do xmm1
	divss xmm0, xmm1			;dzielenie sumy 16 wag wartosci koloru green przez ilosc zsumowanych elementow(9)
	cvtss2si eax, xmm0			;wpisanie wyniku do eax
	mov GreenValue,eax			;wpisanie wyniku dzielenia do zmiennej GreenValue

	;obliczenie wartosci blue pixela wynikowego

	mov eax,BlueValue			;wpisanie BlueValue do eax
	cvtsi2ss xmm0, eax			;wpisanie eax(suma 16 wag wartosci koloru blue) do xmm0
	mov eax, 16					;wpisanie 16 do eax
	cvtsi2ss xmm1, eax			;wpisanie eax(16) do xmm1
	divss xmm0, xmm1			;dzielenie sumy 16 wag wartosci koloru blue przez ilosc zsumowanych elementow(9)
	cvtss2si eax, xmm0			;wpisanie wyniku do eax
	mov BlueValue,eax			;wpisanie wyniku dzielenia do zmiennej BlueValue

	;zapis do tablicy wynikowej
	
	sub rbx, input				;odejmuje adres poczatku tablicy wejsciowej
	add rbx, output				;dodaje poczatek adresu tablicy wyjsciowej
	sub rbx, imageWidth			;odejmuje szerokosc obrazu(szerokosc w pixelach*3(kolory RGB)) aby przejsc do srodkowego rzedu
	sub rbx, 5					;odejmuje 5 aby przejsc do koloru R srodowego pixela
	mov eax, RedValue	    	;wpisuje wartosc koloru red do eax
	mov [rbx], AL				;wpisuje wartosc koloru red do tablicy wyjsciowej
	add rbx, 1					;przechodze do kolejnego koloru (green)
	mov eax, GreenValue 		;wpisuje wartosc koloru green do eax
	mov [rbx], AL				;wpisuje wartosc koloru green do tablicy wyjsciowej
	add rbx, 1					;przechodze do kolejnego koloru (blue)
	mov eax, BlueValue		    ;wpisuje wartosc koloru blue do eax
	mov [rbx], AL				;wpisuje wartosc koloru blue do tablicy wyjsciowej

	;sprawdzenie warynkow koncowych i przejscie do nastepnego obrotu petli

	mov rax, pozX				;wpisuje pozycje X pixela do rax
	cmp rax, x_max				;sprawdzam czy osiagnieto maxymalna pozycje X pixela
	JB PETLAX					;jesli nie osiagnieto - przechodze do petli

	mov rax, pozY				;wpisuje pozycje Y pixela do rax		
	cmp rax, y_max				;sprawdzam czy osiagnieto maxymalna pozycje Y pixela
	JB PETLAY					;jesli nie osiagnieto - przechodze do petli

	;zerowanie rejestrow
	xor rax, rax		;zerowanie rax
	xor rbx, rbx		;zerowanie rbx
	xor rcx, rcx		;zerowanie rcx
	xor rdx, rdx		;zerowanie rdx

	;przywracanie rejestrow
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop RBX
	pop RSI
	pop RSP
	pop RDI
	pop RBP
	
	ret
MyProc1 endp

end