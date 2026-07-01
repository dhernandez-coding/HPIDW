CREATE VIEW BlueBooksAbbreviations
as
(
select  PracticeAbbreviation 
    from dim.vPractices
    where 1=1
    and PracticeIsActive = 1
    and PracticeCompany not in ('CH','EXTERNAL')
)
GO
