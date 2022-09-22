CREATE DATABASE Curso

USE Curso;

CREATE TABLE Aluno (
	RA INT NOT NULL,
	Nome varchar(50) NOT NULL,
	CONSTRAINT PK_Aluno PRIMARY KEY (RA)
);

INSERT INTO Aluno (RA, Nome)
	VALUES (1, 'Weslen'),
		(2, 'Michele'),
		(3, 'Almeida'),
		(4, 'Thalya'),
		(5, 'Louise'),
		(6, 'Felipe'),
		(7, 'Baratão'),
		(8, 'Moranguinho'),
		(9, 'Davi'),
		(10, 'Tiago');

CREATE TABLE Disciplina (
	Sigla char(3) NOT NULL,
	Nome varchar(20) NOT NULL,
	Carga_Horaria int NOT NULL,
	CONSTRAINT PK_Disciplina PRIMARY KEY (Sigla)
);

INSERT INTO Disciplina (Sigla, Nome, Carga_Horaria)
	VALUES ('CA1', 'Calculo 1', 100),
		('CA2', 'Calculo 2', 100),
		('CA3', 'Calculo 3', 100),
		('ED1', 'Estr de Dados 1', 100),
		('ED2', 'Estr de Dados 2', 100),
		('ED3', 'Estr de Dados 3', 100),
		('LP1', 'Log Programação 1', 100),
		('LP2', 'Log Programação 2', 100),
		('LP3', 'Log Programação 3', 100),
		('TCC', 'Trab Conc Curso', 100);

CREATE TABLE Matricula(
	RA int NOT NULL,
	Sigla char(3) NOT NULL,
	Data_Ano int NOT NULL,
	Data_Semestre int NOT NULL,
	Falta int NULL,
	Nota_N1 float,
	Nota_N2 float,
	Nota_Sub float,
	Nota_Media float,
	Situacao bit,

	CONSTRAINT PK_Matricula PRIMARY KEY (RA, Sigla, Data_Ano, Data_Semestre),
	FOREIGN KEY (RA) REFERENCES Aluno(RA),
	FOREIGN KEY (Sigla) REFERENCES Disciplina(Sigla)
	
);

INSERT INTO Matricula (RA, Sigla, Data_Ano, Data_Semestre)
	VALUES (1, 'CA1', 2021, 2),
	(3, 'CA1', 2021, 2),
	(4, 'CA1', 2021, 2),
	(5, 'ED1', 2021, 2),
	(5, 'ED2', 2021, 2),
	(5, 'ED3', 2021, 2),
	(8, 'LP1', 2021, 2),
	(9, 'LP1', 2021, 2),
	(2, 'LP1', 2021, 2),
	(10, 'TCC', 2021, 2);

CREATE TRIGGER TRG_Matricula
On Matricula
AFTER UPDATE 
AS
BEGIN 
	DECLARE
	@Nota1 DECIMAL(10,1),
	@Nota2 DECIMAL(10,1),
	@Media DECIMAL(10,1),
	@Sub DECIMAL(10,1),
	@Ra int,
	@Sigla char(3),
	@Falta int,
	@Carga_Horaria int,
	@Situacao bit
	
	/* Atualiza a frequencia do aluno e situação*/
	SELECT @Nota1 = Nota_N1, @Nota2 = Nota_N2, @Ra = RA, @Sigla = Sigla, @Sub = Nota_Sub, @Falta = Falta FROM INSERTED
	SELECT @Carga_Horaria = Carga_Horaria FROM Disciplina WHERE Disciplina.Sigla = @Sigla
	UPDATE Matricula SET Situacao = 1
	WHERE   RA = @Ra AND Sigla = @Sigla AND Falta < @Carga_Horaria * 0.25 AND Data_Ano = 2021

	UPDATE Matricula SET Situacao = 0,
		Nota_Media = NULL
	WHERE   RA = @Ra AND Sigla = @Sigla AND Falta > @Carga_Horaria * 0.25 AND Data_Ano = 2021

	/*Atualiza todas as notas e situação do aluno*/
	SELECT @Nota1 = Nota_N1, @Nota2 = Nota_N2, @Ra = RA, @Sigla = Sigla, @Sub = Nota_Sub FROM INSERTED 
	UPDATE Matricula SET Nota_Media = (@Nota1 + @Nota2) / 2
	WHERE RA = @Ra AND Sigla = @Sigla AND Situacao = 1
	
	SELECT @Media = Nota_Media, @Nota1 = Nota_N1, @Nota2 = Nota_N2, @Ra = RA, @Sigla = Sigla, @Sub = Nota_Sub FROM INSERTED
	UPDATE Matricula SET Nota_Media = (@Nota1 + @Sub) /2 
	WHERE RA = @Ra AND Sigla = @Sigla AND Situacao = 1 AND Nota_Sub > 0 AND Nota_Media < 5 AND Nota_N1 > Nota_N2 AND Data_Ano = 2021 
	
	UPDATE Matricula SET Nota_Media = (@Nota1 + @Sub) /2 
	WHERE RA = @Ra AND Sigla = @Sigla AND Situacao = 1 AND Nota_Sub > 0 AND Nota_Media < 5 AND Nota_N1 = Nota_N2 AND Data_Ano = 2021

	UPDATE Matricula SET Nota_Media = (@Nota2 + @Sub) /2 
	WHERE RA = @Ra AND Sigla = @Sigla AND Situacao = 1 AND Nota_Sub > 0 AND Nota_Media < 5 AND Nota_N1 < Nota_N2 AND Data_Ano = 2021

	UPDATE Matricula SET Situacao = 0
	WHERE RA = @Ra AND Sigla = @Sigla AND Nota_Media < 5 AND Data_Ano = 2021

	/*Rematricula o Aluno reprovado*/
	INSERT INTO Matricula(RA, Sigla, Data_Ano, Data_Semestre)
		(SELECT RA, Sigla, 2022, 2 FROM Matricula WHERE RA = @Ra AND Sigla = @Sigla AND Situacao = 0 )

END

/* Insere notas e faltas*/
UPDATE Matricula 
	SET Nota_N1 = 3, 
		Nota_N2 = 3,
		Falta = 8,
		Nota_Sub = 4
	WHERE RA = 1 

UPDATE Matricula 
	SET Nota_N1 = 5, 
		Nota_N2 = 3,
		Falta = 20,
		Nota_Sub = 9
	WHERE RA = 2

UPDATE Matricula 
	SET Nota_N1 = 10, 
		Nota_N2 = 8,
		Falta = 80
	WHERE RA = 3

UPDATE Matricula 
	SET Nota_N1 = 3, 
		Nota_N2 = 2,
		Falta = 70
	WHERE RA = 4

UPDATE Matricula 
	SET Nota_N1 = 10, 
		Nota_N2 = 9,
		Falta = 80
	WHERE RA = 5 AND Sigla = 'ED1'

UPDATE Matricula 
	SET Nota_N1 = 8, 
		Nota_N2 = 5,
		Falta = 10
	WHERE RA = 5 AND Sigla = 'ED2'

UPDATE Matricula 
	SET Nota_N1 = 5, 
		Nota_N2 = 3,
		Falta = 5,
		Nota_Sub = 9
	WHERE RA = 5 AND Sigla = 'ED3'

/*Quais são alunos de uma determinada disciplina ministrada no ano de 2021, com suas notas, faltas e Situação Final.*/
SELECT a.RA, a.Nome as 'Aluno', d.Nome 'Disciplina', m.Situacao, m.Nota_N1, m.Nota_N2,m.Nota_Sub, m.Nota_Media,m.Falta
	FROM Aluno a, Matricula m, Disciplina d
	WHERE a.RA = m.RA AND m.Sigla = d.Sigla AND m.Sigla = 'CA1'

/*Quais são as notas, faltas e situação final (Boletim) de um aluno em todas as disciplinas por ele cursadas no ano de 2021, no segundo semestre.*/
SELECT a.RA, a.Nome as 'Aluno', d.Nome 'Disciplina', m.Situacao, m.Nota_N1, m.Nota_N2,m.Nota_Sub, m.Nota_Media, m.Falta
	FROM Aluno a, Matricula m, Disciplina d
	WHERE a.RA = m.RA AND m.Sigla = d.Sigla AND a.RA = 5 AND Data_Ano = 2021

/*Quais são os alunos reprovados por nota (média inferior a cinco) no ano de 2021 e, o nome das disciplinas em que eles reprovaram, com suas notas e médias.*/
SELECT a.RA, a.Nome as 'Aluno', d.Nome 'Disciplina', m.Situacao, m.Nota_N1, m.Nota_N2,m.Nota_Sub, m.Nota_Media, m.Falta
	FROM Aluno a, Matricula m, Disciplina d
	WHERE a.RA = m.RA AND m.Sigla = d.Sigla AND m.Situacao = 0 AND m.Nota_Media < 5


SELECT * FROM Matricula