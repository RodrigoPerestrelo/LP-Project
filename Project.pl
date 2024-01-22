%Rodrigo Salvador dos Santos Perestrelo, 106074
%Este documento visa dar as minhas respostas ao enunciado do Projeto1.

:- set_prolog_flag(answer_write_options,[max_depth(0)]). % para listas completas
:- ['dados.pl'], ['keywords.pl']. % ficheiros a importar.

%PREDICADOS AUXILIARES

/* Predicado auxiliar para ajudar a melhor procurar por periodos na base de dados
O predicado cria uma lista com os proprios periodos fornecidos e insere p1_2 ou p3_4,conforme os periodos fornecidos,
para que seja possivel procurar as disciplinas semestrais desses periodos.
Utilizamos o sort para ordenar a lista e retirar elementos repetidos, caso seja o caso.  */

aux_periodo(ListaPeriodos, ListaPeriodos_final) :-
    findall(X, insere(ListaPeriodos, X), ListaPeriodos_final_NotSorted),
    sort(ListaPeriodos_final_NotSorted,ListaPeriodos_final).

insere(ListaPeriodos, X) :- member(X, ListaPeriodos).
insere(ListaPeriodos, p1_2) :- member(p1, ListaPeriodos).
insere(ListaPeriodos, p1_2) :- member(p2, ListaPeriodos).
insere(ListaPeriodos, p3_4) :- member(p3, ListaPeriodos).
insere(ListaPeriodos, p3_4) :- member(p4, ListaPeriodos).


%QUALIDADE DOS DADOS

/* eventosSemSalas(EventosSemSala) e verdade se 'EventosSemSala' e uma lista, ordenada e sem elementos repetidos, de IDs de eventos sem sala */
%utilizamos o findall para criar uma lista com os Ids dos eventos semSala
%utilizamos o sort para ordenar a lista e retirar elementos repetidos

eventosSemSalas(EventosSemSala) :-
    findall(Ids_eventos,evento(Ids_eventos,_,_,_,semSala),Eventos_NotSorted),
    sort(Eventos_NotSorted,EventosSemSala).

/* eventosSemSalasDiaSemana(DiaDaSemana, EventosSemSala) e verdade se 'EventosSemSala' e uma lista, ordenada e sem elementos repetidos,
de IDs de eventos sem sala que decorrem em DiaDaSemana */
%utilizamos o predicado eventosSemSalas para encontrar os Ids dos eventos semSala
%utilizamos o findall para criar uma lista, utilizando os Ids fornecidos pelo predicado eventosSemSalas, dos Ids semSala que decorrem em DiaDaSemana
%utilizamos o sort para ordenar a lista e retirar elementos repetidos

eventosSemSalasDiaSemana(DiaDaSemana,EventosSemSala) :-
    eventosSemSalas(Eventos_aux),
    findall(Id_evento,(member(Id_evento,Eventos_aux),horario(Id_evento,DiaDaSemana,_,_,_,_)),Eventos_NotSorted),
    sort(Eventos_NotSorted,EventosSemSala).

/* eventosSemSalasPeriodo(ListaPeriodos, EventosSemSala) e verdade se 'ListaPeriodos' e uma lista de periodos
e 'EventosSemSala' e uma lista, ordenada e sem elementos repetidos, de IDs de eventos sem sala nos periodos de 'ListaPeriodos'. */
%utilizamos o predicado eventosSemSalas para encontrar os Ids dos eventos semSala
%utilizamos o predicado auxiliar aux_periodo, para que modifique a lista de forma a termos em conta as disciplinas semestrais
%utilizamos o findall para criar uma lista, utilizando os Ids fornecidos pelo predicado eventosSemSalas, dos Ids semSala que decorrem nos Periodos fornecidos
%utilizamos o sort para ordenar a lista e retirar elementos repetidos

eventosSemSalasPeriodo(ListaPeriodos,EventosSemSala) :-
    eventosSemSalas(Eventos_aux),
    aux_periodo(ListaPeriodos,ListaPeriodos_final),
    findall(Id_evento,(member(Id_evento,Eventos_aux),horario(Id_evento,_,_,_,_,Periodo),member(Periodo,ListaPeriodos_final)),Eventos_NotSorted),
    sort(Eventos_NotSorted,EventosSemSala).


%PESQUISA SIMPLES

/*  organizaEventos(ListaEventos, Periodo, EventosNoPeriodo) e verdade se 'EventosNoPeriodo' e a lista, ordenada e sem elementos repetidos,
de IDs dos eventos de 'ListaEventos' que ocorrem no periodo 'Periodo'.  (sem usar predicados de ordem superior) */

%Criamos uma organizaEventos auxilar dentro dela com mais uma variavel
%utilizamos o sort para ordenar a lista e retirar elementos repetidos
%o operador corte diz-nos que apenas pretendemos a primeira solucao fornecida pelo programa

organizaEventos(ListaEventos, Periodo, EventosNoPeriodo) :-
    organizaEventos(ListaEventos,Periodo,[],EventosNoPeriodo_NotSorted),
    sort(EventosNoPeriodo_NotSorted,EventosNoPeriodo),
    !.

%o caso terminal sera quando ja tivermos avaliado todos os Ids da ListaEventos

organizaEventos([],_,EventosNoPeriodo,EventosNoPeriodo).

%Avaliamos um id de cada vez, 'Cabeca', e verificamos se ocorre no periodo fornecido, sem esquecer as disciplinas semestrais
%Se esse for o caso, damos 'append' do Id ('Cabeca') ao acumulador

organizaEventos([Cabeca|Cauda_ListaEventos], Periodo, EventosNoPeriodo_Acumulador,EventosNoPeriodo) :-
    horario(Cabeca,_,_,_,_,Periodo_ID),
    aux_periodo([Periodo],ListaPeriodos),
    member(Periodo_ID,ListaPeriodos),
    append(EventosNoPeriodo_Acumulador,[Cabeca],EventosNoPeriodo_Acumulador_2),
    organizaEventos(Cauda_ListaEventos,Periodo,EventosNoPeriodo_Acumulador_2,EventosNoPeriodo).

%Se nao, chamamos o proximo Id da ListaEventos

organizaEventos([_|Cauda_ListaEventos], Periodo, EventosNoPeriodo_Acumulador,EventosNoPeriodo) :-
    organizaEventos(Cauda_ListaEventos,Periodo,EventosNoPeriodo_Acumulador,EventosNoPeriodo).


/* eventosMenoresQue(Duracao, ListaEventosMenoresQue) e verdade se 'ListaEventosMenoresQue' e a lista ordenada e sem elementos repetidos
dos identificadores dos eventos que tem duracao menor ou igual a 'Duracao'. */
%utilizamos o findall para criar uma lista com os Ids dos eventos que tem duracao menor ou igual a 'Duracao'
%utilizamos o sort para ordenar a lista e retirar elementos repetidos

eventosMenoresQue(Duracao,ListaEventosMenoresQue) :-
    findall(ID,(horario(ID,_,_,_,Duracao_Evento,_),(Duracao_Evento =< Duracao)),ListaEventosMenoresQue),
    sort(ListaEventosMenoresQue,_).

/* eventosMenoresQueBool(ID, Duracao) e verdade se o evento identificado por ID tiver duracao igual ou menor a Duracao, ou false caso contrario. */
%e apenas necessario encontrar a duracao do evento, com o ID do mesmo e verificar se e menor que a 'Duracao' fornecida

eventosMenoresQueBool(ID,Duracao) :-
    horario(ID,_,_,_,Duracao_Evento,_),
    Duracao_Evento =< Duracao.

/* procuraDisciplinas(Curso, ListaDisciplinas) e verdade se 'ListaDisciplinas' e a lista ordenada alfabeticamente do nome das disciplinas do curso 'Curso'. */
%utilizamos o findall para criar uma lista com todas as disciplinas de um 'Curso', atraves da obtencao de um ID de um turno do mesmo
%utilizamos o sort para ordenar a lista e retirar elementos repetidos

procuraDisciplinas(Curso,ListaDisciplinas) :-
    findall(Disciplina,(evento(ID,Disciplina,_,_,_),turno(ID,Curso,_,_)),ListaDisciplinas_NotSorted),
    sort(ListaDisciplinas_NotSorted,ListaDisciplinas).

/* organizaDisciplinas(ListaDisciplinas, Curso, Semestres) e verdade se 'Semestres' e uma lista com duas listas.
A lista na primeira posicao contem as disciplinas de 'ListaDisciplinas' do curso 'Curso' que ocorrem no primeiro semestre;
a lista na segunda posicao contem as que ocorrem no segundo semestre.
Ambas as listas devem estar ordenadas alfabeticamente e nao devem ter elementos repetidos.
O predicado falha se nao existir no curso 'Curso' uma disciplina de 'ListaDisciplinas'. (sem usar predicados de ordem superior)*/

%Criamos uma organizaDisciplinas auxilar dentro dela com mais uma variavel
%utilizamos o sort para ordenar a lista e retirar elementos repetidos
%o operador corte diz-nos que apenas pretendemos a primeira solucao fornecida pelo programa

organizaDisciplinas(ListaDisciplinas, Curso, Semestres) :-
    organizaDisciplinas(ListaDisciplinas,Curso,[[],[]],Semestres_NotSorted),
    sort(Semestres_NotSorted,Semestres),
    !.

%o caso terminal sera quando ja tivermos avaliado todas as disciplinas da 'ListaDisciplinas'

organizaDisciplinas([],_,Semestres,Semestres).

%Avaliamos uma disciplina de cada vez, 'Cabeca', e verificamos , sem esquecer as disciplinas semestrais
%utilizando a disciplina e o Curso, encontramos um ID comum que nos ira indicar em que periodo a disciplina ocorre
%Se o periodo em que ocorre coincidir com o primeiro semestre, damos 'append' da disciplina ('Cabeca') a lista correspondente as
%disciplinas do primeiro semestre

organizaDisciplinas([Cabeca|Cauda_ListaDisciplinas],Curso,[Semestre1,Semestre2],Semestres) :-
    evento(ID,Cabeca,_,_,_),
    turno(ID,Curso,_,_),
    horario(ID,_,_,_,_,Periodo),
    member(Periodo,[p1,p1_2,p2]),
    append(Semestre1,[Cabeca],Semestre_Acumulador_1),
    organizaDisciplinas(Cauda_ListaDisciplinas,Curso,[Semestre_Acumulador_1,Semestre2],Semestres).

%Se o periodo em que ocorre coincidir com o segundo semestre, damos 'append' da disciplina ('Cabeca') a lista correspondente as
%disciplinas do segundo semestre

organizaDisciplinas([Cabeca|Cauda_ListaDisciplinas],Curso,[Semestre1,Semestre2],Semestres) :-
    evento(ID,Cabeca,_,_,_),
    turno(ID,Curso,_,_),
    horario(ID,_,_,_,_,Periodo),
    member(Periodo,[p3,p3_4,p4]),
    append(Semestre2,[Cabeca],Semestre_Acumulador_2),
    organizaDisciplinas(Cauda_ListaDisciplinas,Curso,[Semestre1,Semestre_Acumulador_2],Semestres).


/*  horasCurso(Periodo, Curso, Ano, TotalHoras) e verdade se 'TotalHoras' for o numero de horas total dos eventos associadas ao curso 'Curso',
no ano 'Ano' e periodo 'Periodo'(nao esquecer as disciplinas semestrais). */
%se varios turnos partilharem o mesmo evento, o numero de horas do evento deve contar apenas uma vez.
%utilizamos o predicado auxiliar aux_periodo, para que modifique a lista de forma a termos em conta as disciplinas semestrais
%utilizamos o primeiro findall para criar uma lista com os IDs dos eventos de um 'Curso' num dado 'Ano'
%utilizamos o sort para ordenar a lista e retirar elementos repetidos, que e o pretendido neste caso, assim nao contabilizamos varios turnos num certo evento
%utilizamos o segundo findall para criar uma lista com as duracoes de cada evento, que decorrem no periodo pretendido
%utilizamos o sumlist para devolver a soma dos valores da lista que tinha as duracoes dos eventos

horasCurso(Periodo, Curso, Ano, TotalHoras) :-
    aux_periodo([Periodo],Lista_Periodo),
    findall(ID,turno(ID,Curso,Ano,_),Lista_ID_NotSorted),
    sort(Lista_ID_NotSorted,Lista_ID),
    findall(Duracao,(member(IDs,Lista_ID),member(Periodo_ID,Lista_Periodo),horario(IDs,_,_,_,Duracao,Periodo_ID)),TotalHoras_lista),
    sumlist(TotalHoras_lista,TotalHoras).

/* evolucaoHorasCurso(Curso, Evolucao) e verdade se 'Evolucao' for uma lista de tuplos na forma (Ano, Periodo, NumHoras),
em que 'NumHoras' e o total de horas associadas ao curso 'Curso', no ano 'Ano' e periodo 'Periodo'.
Evolucao devera estar ordenada por ano (crescente) e periodo.*/
%utilizamos o findall para criar uma lista com os tuplos pretendido '(Ano, Periodo, NumHoras)'
%em que: 'Ano' tem que ser 1,2 ou 3 e 'Periodo' tem que corresponder a um dos quatro periodos (p1,p2,p3,p4)
%assim, utilizamos o predicado definido anteriormente para que se obtenha as horas de um curso num dado ano e periodo

evolucaoHorasCurso(Curso, Evolucao) :-
    findall((Ano,Periodo,TotalHoras),(member(Ano,[1,2,3]),member(Periodo,[p1,p2,p3,p4]),horasCurso(Periodo,Curso,Ano,TotalHoras)),Evolucao).


%OCUPACOES CRITICAS DE SALAS

/* ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento, HoraFimEvento, Horas) e verdade se 'Horas' for o numero de horas sobrepostas
entre o evento que tem inicio em 'HoraInicioEvento' e fim em 'HoraFimEvento', e o slot que tem inicio em 'HoraInicioDada' e fim em 'HoraFimDada'. */
%se a hora de inicio do evento for superior (ou igual) a hora de inicio do slot e a hora de fim do evento inferior (ou igual) a hora de fim do slot, as horas sobrepostas sao dadas pela diferenca entre a hora de fim do evento e a hora de inicio do evento
%se a hora de inicio do evento for superior (ou igual) a hora de inicio do slot e a hora de fim do evento superior a hora de fim do slot, as horas sobrepostas sao dadas pela diferenca entre a hora de fim do slot e a hora de inicio do evento
%se a hora de inicio do evento for inferior (ou igual) a hora de inicio do slot e a hora de fim do evento superior (ou igual) a hora de fim do slot, as horas sobrepostas sao dadas pela diferenca entre a hora de fim do slot e a hora de inicio do slot
%se a hora de inicio do evento for inferior (ou igual) a hora de inicio do slot e a hora de fim do evento inferior (ou igual) a hora de fim do slot, as horas sobrepostas sao dadas pela diferenca entre a hora de fim do evento e a hora de inicio do slot
%garante-se sempre que o resultado das horas sobrepostas tem que ser positivo
%quando se achar uma linha com as condicoes validas para o caso, e for calculada as horas sobrepostas, o predicado nao continua a avaliar outras possiveis linhas, devido ao operador corte

ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento,HoraFimEvento, Horas) :-
    (HoraInicioEvento >= HoraInicioDada,HoraFimEvento =< HoraFimDada),(Horas is (HoraFimEvento - HoraInicioEvento),Horas>0),!;
    (HoraInicioEvento >= HoraInicioDada,HoraFimEvento > HoraFimDada),(Horas is (HoraFimDada - HoraInicioEvento),Horas>0),!;
    (HoraInicioEvento =< HoraInicioDada,HoraFimEvento >= HoraFimDada),(Horas is (HoraFimDada - HoraInicioDada),Horas>0),!;
    (HoraInicioEvento =< HoraInicioDada,HoraFimEvento =< HoraFimDada),(Horas is (HoraFimEvento - HoraInicioDada),Horas>0),!.

/* numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras) e verdade se 'SomaHoras' for o numero de horas ocupadas nas salas do tipo 'TipoSala',
no intervalo de tempo definido entre 'HoraInicio' e 'HoraFim', no dia da semana 'DiaSemana', e no periodo 'Periodo'. */
%utilizamos o predicado auxiliar aux_periodo, para que modifique a lista de forma a termos em conta as disciplinas semestrais
%encontramos as salas a averiguar atraves do tipo de sala fornecido
%utilizamos o primeiro findall para criar uma lista com os IDs dos eventos que decorrem nas salas
%utilizamos o segundo findall para criar uma lista com os Ids dos eventos que decorrem no periodo e no dia da semana fornecido, a partir dos Ids obtidos anteriormente
%utilizamos o terceiro findall para criar uma lista com as horas ocupadas em cada um dos eventos associados a um ID fornecido do findall anterior:
%   com o Id do evento encontramos a Hora de Inicio e de Fim do Evento e usamos o predicado ocupaSlot para verificar o numero de horas sobrepostas
%utilizamos o sumlist para devolver a soma dos valores da lista que tinha as horas dos eventos 

numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras) :-
    aux_periodo([Periodo],Lista_Periodo_final),
    salas(TipoSala,Salas),
    findall(ID,(member(Sala_evento,Salas),evento(ID,_,_,_,Sala_evento)),IDs_Salas),
    findall(ID,(member(ID,IDs_Salas),member(Periodo_ListaFinal,Lista_Periodo_final),horario(ID,DiaSemana,_,_,_,Periodo_ListaFinal)),Lista_IDs_filtrada),
    findall(Horas,(member(ID,Lista_IDs_filtrada),horario(ID,_,HoraI,HoraF,_,_),ocupaSlot(HoraInicio,HoraFim,HoraI,HoraF,Horas)),Lista_SomaHoras),
    sumlist(Lista_SomaHoras,SomaHoras).

/* ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max) e verdade se 'Max' for o numero de horas possiveis de ser ocupadas por salas do tipo 'TipoSala',
no intervalo de tempo definido entre 'HoraInicio' e 'HoraFim'.
Em termos praticos, assume-se que 'Max' e o intervalo de tempo dado ('HoraFim' - 'HoraInicio'), multiplicado pelo numero de salas em jogo do tipo 'TipoSala'. */
%encontramos as salas do tipo de sala fornecido
%utilizamos 'length' para obter o numero de salas do tipo 'TipoSala'

ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max) :-
   salas(TipoSala,Salas),
   length(Salas,N_Salas),
   Max is ((N_Salas)*(HoraFim-HoraInicio)).

/* percentagem(SomaHoras, Max, Percentagem) e verdade se 'Percentagem' for a divisao de 'SomaHoras' por 'Max', multiplicada por 100. */

percentagem(SomaHoras, Max, Percentagem) :-
    Percentagem is ((SomaHoras/Max)*100).

/* ocupacaoCritica(HoraInicio, HoraFim, Threshold, Resultados) e verdade se 'Resultados' for uma lista ordenada de tuplos do tipo
casosCriticos(DiaSemana, TipoSala, Percentagem) em que 'DiaSemana', 'TipoSala' e 'Percentagem' sao, respectivamente,
um dia da semana, um tipo de sala e a sua percentagem de ocupacao, no intervalo de tempo entre 'HoraInicio' e 'HoraFim',
e supondo que a percentagem de ocupacao relativa a esses elementos esta acima de um dado valor critico ('Threshold'). */
%cria-se uma lista com os dias da semana possiveis
%cria-se uma lista com os periodos possiveis
%utilizamos o primeiro findall para criar uma lista 'TiposSala' com todos os tipos de Sala
%utilizamos o segundo findall para criar uma lista de tuplos do tipo 'casosCriticos(DiaSemana, TipoSala, Percentagem)'
    %os member selecionam um periodo da lista de periodos, um tipo de sala da lista 'TiposSala' e um dia da semana da lista com os dias da semana possiveis, fazendo todas as combinacoes possiveis
    %utilizamos o predicado 'numHorasOcupadas' para obter o numero de horas ocupadas
    %utilizamos o predicado 'ocupacaoMax' para obter o numero de horas possiveis de ser ocupadas
    %utilizamos o predicado 'percentagem' para obter a divisao das horas ocupadas pelas horas possiveis de ser ocupadas
    %verificamos se a percentagem resultante e superior a 'Threshold', arredondando a percentagem se isso se verificar
%utilizamos o sort para ordenar a lista (e retirar elementos repetidos)
   
ocupacaoCritica(HoraInicio, HoraFim, Threshold, Resultados) :-
    ListaDiaDaSemana = [segunda-feira,terca-feira,quarta-feira,quinta-feira,sexta-feira],
    ListaPeriodos = [p1,p2,p3,p4],
    findall(Sala_T,(salas(Sala_T,_)),TiposSala),
    
    findall(casosCriticos(DiaDaSemana,Sala_Tipo,Percentagem_arred),
    (member(Periodo,ListaPeriodos),member(Sala_Tipo,TiposSala), member(DiaDaSemana,ListaDiaDaSemana),
    numHorasOcupadas(Periodo,Sala_Tipo,DiaDaSemana,HoraInicio,HoraFim,SomaHoras),
    ocupacaoMax(Sala_Tipo,HoraInicio,HoraFim,Max),
    percentagem(SomaHoras,Max,Percentagem),
    (Percentagem > Threshold),
    ceiling(Percentagem,Percentagem_arred)),Resultados_NotSorted),
    sort(Resultados_NotSorted,Resultados).


%OCUPACAO MESA

/* ocupacaoMesa(ListaPessoas, ListaRestricoes, OcupacaoMesa) e verdade se 'ListaPessoas' for a lista com o nome das pessoas a sentar a mesa, 'ListaRestricoes'
for a lista de restricoes a verificar e 'OcupacaoMesa' for uma lista com tres listas, em que a primeira contem as pessoas de um lado da mesa (X1, X2 e X3),
a segunda as pessoas a cabeceira (X4 e X5) e a terceira as pessoas do outro lado da mesa (X6, X7 e X8), de modo a que essas pessoas sao exactamente as da 'ListaPessoas'
e verificam todas as restricoes de ListaRestricoes. */
%utilizamos 'permutation' para criar uma permutacao com as pessoas dadas na 'ListaPessoas'
%cria-se uma 'HipoteseMesa' com a permutacao criada
%avalia-se se essa mesa cumpre todas as restricoes
%se isso acontecer, entao encontramos a solucao e dizemos que a hipotese e, de facto, a ocupacao da mesa a retornar

ocupacaoMesa(ListaPessoas, ListaRestricoes, OcupacaoMesa) :-
    permutation(ListaPessoas,[Pessoa1,Pessoa2,Pessoa3,Pessoa4,Pessoa5,Pessoa6,Pessoa7,Pessoa8]),
    HipoteseMesa = [[Pessoa1,Pessoa2,Pessoa3], [Pessoa4,Pessoa5], [Pessoa6,Pessoa7,Pessoa8]],
    auxiliar_restricoes(ListaRestricoes,HipoteseMesa),
    OcupacaoMesa = HipoteseMesa.

%A 'auxiliar_restricoes' ira verificar as restricoes da 'ListaRestricoes' fornecida uma a uma
%o caso terminal e quando a 'ListaRestricoes' se encontra vazia, ou seja, nao ha mais restricoes a serem tidas em conta

auxiliar_restricoes([],_).

%obtem-se a primeira restricao que se encontra na lista de restricoes
%executa-se a restricao usando um functor
%chama-se novamente o predicado com a restante lista de restricoes

auxiliar_restricoes([Rest|Lista_Rest],HipoteseMesa) :-
    Executar_restricao =.. [restricao|[Rest,HipoteseMesa]],
    Executar_restricao,
    auxiliar_restricoes(Lista_Rest,HipoteseMesa).

%Lista de restricoes:
% cada 'restricao' possui o nome da restricao e as pessoas que afeta, e a sua consequencia na mesa

restricao(cab1(NomePessoa),[_,[NomePessoa,_],_]).

restricao(cab2(NomePessoa),[_,[_,NomePessoa],_]).

restricao(honra(NomePessoa1,NomePessoa2),[[_,_,_],[NomePessoa1,_],[NomePessoa2,_,_]]).
restricao(honra(NomePessoa1,NomePessoa2),[[_,_,NomePessoa2],[_,NomePessoa1],[_,_,_]]).

restricao(lado(NomePessoa1,NomePessoa2),[[NomePessoa1,NomePessoa2,_],[_,_],[_,_,_]]).
restricao(lado(NomePessoa1,NomePessoa2),[[NomePessoa2,NomePessoa1,_],[_,_],[_,_,_]]).
restricao(lado(NomePessoa1,NomePessoa2),[[_,NomePessoa1,NomePessoa2],[_,_],[_,_,_]]).
restricao(lado(NomePessoa1,NomePessoa2),[[_,NomePessoa2,NomePessoa1],[_,_],[_,_,_]]).
restricao(lado(NomePessoa1,NomePessoa2),[[_,_,_],[_,_],[NomePessoa1,NomePessoa2,_]]).
restricao(lado(NomePessoa1,NomePessoa2),[[_,_,_],[_,_],[NomePessoa2,NomePessoa1,_]]).
restricao(lado(NomePessoa1,NomePessoa2),[[_,_,_],[_,_],[_,NomePessoa1,NomePessoa2]]).
restricao(lado(NomePessoa1,NomePessoa2),[[_,_,_],[_,_],[_,NomePessoa2,NomePessoa1]]).

restricao(naoLado(NomePessoa1, NomePessoa2), HipoteseMesa) :-
    (\+ restricao(lado(NomePessoa1, NomePessoa2), HipoteseMesa)).

restricao(frente(NomePessoa1,NomePessoa2),[[NomePessoa1,_,_],[_,_],[NomePessoa2,_,_]]).
restricao(frente(NomePessoa1,NomePessoa2),[[NomePessoa2,_,_],[_,_],[NomePessoa1,_,_]]).
restricao(frente(NomePessoa1,NomePessoa2),[[_,NomePessoa1,_],[_,_],[_,NomePessoa2,_]]).
restricao(frente(NomePessoa1,NomePessoa2),[[_,NomePessoa2,_],[_,_],[_,NomePessoa1,_]]).
restricao(frente(NomePessoa1,NomePessoa2),[[_,_,NomePessoa1],[_,_],[_,_,NomePessoa2]]).
restricao(frente(NomePessoa1,NomePessoa2),[[_,_,NomePessoa2],[_,_],[_,_,NomePessoa1]]).

restricao(naoFrente(NomePessoa1, NomePessoa2), HipoteseMesa) :-
    (\+ restricao(frente(NomePessoa1, NomePessoa2), HipoteseMesa)).