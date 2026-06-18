Create View BlueBooksAbbreviations
as
(
select  PracticeAbbreviation 
    from dim.Practices
    where 1=1
    and PracticeIsActive = 1
    and PracticeCompany not in ('CH','EXTERNAL')
)
GO
