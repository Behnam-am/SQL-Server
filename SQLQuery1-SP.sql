/* A storedPrecedure that gets following parameters and makes persian meaningful words.
   @ln	:	length of words enterd as a string seprated with comma. EX: '4,5,6'
   @ch	:	characters enterd as a string seprated with comma. EX: N'ب,ا,ز,آ,ی'

   To run storedPrecedure use code below:
   EXEC dbo.AmirzaProject @ln='4,5,6', @ch=N'ب,ا,ز,آ,ی';
*/

CREATE OR ALTER PROCEDURE AmirzaProject (
    @ln NVARCHAR(MAX)
   ,@ch NVARCHAR(MAX))
AS
BEGIN
	/* Declare table variable "letters" to store given characters */
    DECLARE @letters TABLE (letter NVARCHAR(1));
    INSERT INTO @letters
    SELECT *
    FROM STRING_SPLIT(@ch, ',');

	/* Declare table variable "lengths" to store given length of words */
    DECLARE @lengths TABLE ([length] INT);
    INSERT INTO @lengths
    SELECT *
    FROM STRING_SPLIT(@ln, ',');

	/* Create table "combinations" if it dosen't exists to store any combination of given charecters */
    IF NOT EXISTS
    (
        SELECT *
        FROM sysobjects
        WHERE name = 'combinations'
              AND xtype = 'U'
    )
        CREATE TABLE combinations (word NVARCHAR(MAX));

	/* Clear table "combinations" to make sure it's empty */
    DELETE FROM dbo.combinations;

	/* fill table "combinations" with given charecters */
    INSERT INTO combinations
    SELECT *
    FROM STRING_SPLIT(@ch, ',');


    DECLARE @len INT = (SELECT MAX(length) FROM @lengths)

    DECLARE @i INT = 1;

	/* Create characters combinations with cross join and insert in "combinations" table */
    WHILE @i < @len
    BEGIN
        INSERT INTO dbo.combinations
        SELECT CONCAT(cmb.word, ltr.letter)
        FROM dbo.combinations AS cmb
            CROSS JOIN @letters AS ltr;
        SET @i = @i + 1;
    END;

	/* Choose meaningful words using inner join on "combinations" and "wordsList" tables */
	WITH cte AS(
    SELECT DISTINCT
            lst.orginalWord
			,lst.WordLength
            ,lst.meaning
    FROM dbo.combinations AS cmb
        INNER JOIN dbo.wordsList AS lst
            ON cmb.word = lst.word
	WHERE lst.WordLength IN (SELECT * FROM @lengths))

	/* Sort meaningful words and show them as a table */
	SELECT
		orginalWord AS [کلمه]
	   ,WordLength AS [تعداد کاراکتر]
	   ,meaning AS [معنی کلمه]
	FROM cte
	ORDER BY cte.WordLength
			,cte.orginalWord;

END;